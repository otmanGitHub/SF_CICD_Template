# Pipeline CI/CD Salesforce - Schémas Visuels

Ce document présente les schémas visuels illustrant l'architecture et le flux du pipeline CI/CD.

---

## Schéma 1 : Vue d'ensemble simplifiée

```mermaid
flowchart TD
    A[🔔 Déclencheur: PR Créée/Mise à jour] --> B[📦 Phase 1: Setup<br/>Node.js + SF CLI + Java + Plugins<br/>⏱️ 5-8 min]
    B --> C[🔐 Phase 2: Authentification<br/>Salesforce Org + GitHub CLI<br/>⏱️ 1 min]
    C --> D[🔄 Phase 3: Génération Delta<br/>Comparaison Git + Ajout tests<br/>⏱️ 2-5 min]
    D --> E[🔍 Phase 4: Analyse Qualité<br/>PMD + ESLint<br/>⏱️ 2-5 min]
    D --> F[⚡ Phase 5: Validation Flows<br/>Flow Scanner<br/>⏱️ 1-3 min]
    E --> G{SARIF vide?}
    G -->|Non| H[📤 Upload SARIF vers<br/>GitHub Security]
    G -->|Oui| I[⏭️ Skip Upload]
    F --> J{Flows détectés?}
    J -->|Oui| K[💬 Commentaire PR<br/>avec résultats]
    J -->|Non| L[⏭️ Skip Flow Scan]
    H --> M
    I --> M
    K --> M
    L --> M
    M[🚀 Phase 6: Validation Salesforce<br/>Deploy --dry-run + RunLocalTests<br/>⏱️ 5-30 min]
    M --> N{Résultat}
    N -->|✅ Success| O[✅ PR Validée<br/>Merge autorisé]
    N -->|❌ Failure| P[❌ Corrections requises<br/>Voir logs + commentaires]

    style A fill:#e1f5ff
    style O fill:#d4edda
    style P fill:#f8d7da
    style M fill:#fff3cd
```

**Durée totale moyenne** : 10-20 minutes
**Durée maximale** : ~30 minutes (selon la taille des tests)

---

## Schéma 2 : Flux détaillé par composants

```mermaid
graph TB
    subgraph "🎯 DÉCLENCHEUR"
        T1[Pull Request:<br/>opened/synchronize]
        T2[Filtre: force-app/**]
        T1 --> T2
    end

    subgraph "⚙️ SETUP & AUTH"
        S1[Install Node 22]
        S2[Install SF CLI 2.108.6]
        S3[Install Java OpenJDK 21]
        S4[Install Plugins:<br/>code-analyzer, sgd, flow-scanner]
        S5[Auth Salesforce via SFDX URL]
        S6[Auth GitHub CLI]
        S1 --> S2 --> S3 --> S4 --> S5
        S4 --> S6
    end

    subgraph "📦 DELTA GENERATION"
        D1[sf sgd source delta<br/>Compare HEAD vs Base SHA]
        D2[Extraire métadonnées modifiées<br/>dans changed-sources/]
        D3[Détecter classes Apex modifiées]
        D4[Ajouter classes Test associées]
        D1 --> D2 --> D3 --> D4
    end

    subgraph "🔍 ANALYSE QUALITÉ"
        Q1[sf code-analyzer run<br/>PMD + ESLint]
        Q2[Générer pmdScanResults.sarif.json]
        Q3{jq: SARIF vide?}
        Q4[Upload vers GitHub Security]
        Q1 --> Q2 --> Q3
        Q3 -->|Non| Q4
    end

    subgraph "⚡ FLOWS VALIDATION"
        F1{Flows détectés?}
        F2[sf flow:scan]
        F3[Formatter résultats avec Python]
        F4[gh pr comment sur PR]
        F1 -->|Oui| F2 --> F3 --> F4
    end

    subgraph "🚀 SALESFORCE VALIDATION"
        V1[sf project deploy start<br/>--dry-run --test-level RunLocalTests]
        V2[Exécution tests Apex]
        V3[Calcul couverture de code]
        V4{Tests + Couverture OK?}
        V1 --> V2 --> V3 --> V4
    end

    subgraph "📊 RÉSULTATS"
        R1[✅ Workflow Success]
        R2[❌ Workflow Failure]
        R3[Logs détaillés dans Checks]
        R4[Commentaire Flow sur PR]
        R5[Alerts dans Security tab]
        V4 -->|Oui| R1
        V4 -->|Non| R2
        R1 --> R3
        R2 --> R3
        F4 --> R4
        Q4 --> R5
    end

    T2 ==> S1
    S6 ==> D1
    D4 ==> Q1
    D4 ==> F1
    Q3 ==> V1
    F1 ==> V1

    style T1 fill:#e1f5ff
    style R1 fill:#d4edda
    style R2 fill:#f8d7da
    style V1 fill:#fff3cd
```

---

## Schéma 3 : Traitement parallèle Phase 4 & 5

```mermaid
graph LR
    A[Delta Package Prêt] --> B[🔍 Phase 4:<br/>Code Analyzer]
    A --> C[⚡ Phase 5:<br/>Flow Scanner]

    B --> B1[Run PMD]
    B --> B2[Run ESLint]
    B1 --> D[Generate SARIF]
    B2 --> D
    D --> E{Résultats?}
    E -->|Oui| F[Upload to Security]
    E -->|Non| G[Skip]

    C --> C1{Flows présents?}
    C1 -->|Oui| C2[Scan flows]
    C1 -->|Non| C3[Skip]
    C2 --> C4[Format results]
    C4 --> C5[Post PR comment]

    F --> H[Phase 6: Validation SF]
    G --> H
    C5 --> H
    C3 --> H

    style A fill:#e1f5ff
    style H fill:#fff3cd
```

---

## Schéma 4 : Architecture des outils

```mermaid
graph TB
    subgraph "🛠️ OUTILS INSTALLÉS"
        N[Node.js 22<br/>Runtime JavaScript]
        SF[Salesforce CLI 2.108.6<br/>Commandes sf]
        J[Java OpenJDK 21<br/>Requis pour PMD]
    end

    subgraph "🔌 PLUGINS SF"
        P1[@salesforce/plugin-code-analyzer<br/>v5.5.0]
        P2[sfdx-git-delta<br/>v6.22.0]
        P3[lightning-flow-scanner<br/>v5.7.2]
    end

    subgraph "🔧 OUTILS SYSTÈME"
        GH[GitHub CLI<br/>gh]
        GIT[Git<br/>Avec historique complet]
        JQ[jq<br/>Parser JSON]
        PY[Python 3<br/>Scripts formatage]
    end

    N -.-> SF
    J -.-> P1
    SF --> P1
    SF --> P2
    SF --> P3

    P1 --> |Analyse| CODE[Code Apex/JS]
    P2 --> |Delta| DELTA[Package XML]
    P3 --> |Scan| FLOWS[Flows]

    GH --> |Commentaires| PR[Pull Request]
    JQ --> |Parse| SARIF[Fichiers SARIF]
    PY --> |Format| RESULTS[Résultats Flow]

    style SF fill:#00A1E0
    style CODE fill:#d4edda
    style FLOWS fill:#d4edda
    style DELTA fill:#d4edda
```

---

## Schéma 5 : Décisions conditionnelles

```mermaid
graph TD
    START[Workflow démarre] --> D1{Modifications<br/>dans force-app/?}
    D1 -->|Non| SKIP1[⏭️ Skip workflow]
    D1 -->|Oui| D2{Auteur =<br/>dependabot?}
    D2 -->|Oui| SKIP2[⏭️ Skip workflow]
    D2 -->|Non| SETUP[Setup + Auth + Delta]

    SETUP --> ANALYZE[Code Analyzer run]
    ANALYZE --> D3{SARIF contient<br/>des issues?}
    D3 -->|Non| SKIP3[⏭️ Skip upload SARIF]
    D3 -->|Oui| UPLOAD[📤 Upload to Security]

    SETUP --> D4{Flows modifiés<br/>détectés?}
    D4 -->|Non| SKIP4[⏭️ Skip Flow scan]
    D4 -->|Oui| FLOW[⚡ Flow Scanner]
    FLOW --> COMMENT[💬 Post PR comment]

    UPLOAD --> VALIDATE
    SKIP3 --> VALIDATE
    COMMENT --> VALIDATE
    SKIP4 --> VALIDATE

    VALIDATE[🚀 SF Validation Deploy] --> D5{Tests OK +<br/>Couverture ≥75%?}
    D5 -->|Oui| SUCCESS[✅ Success]
    D5 -->|Non| FAILURE[❌ Failure]

    style SUCCESS fill:#d4edda
    style FAILURE fill:#f8d7da
    style SKIP1 fill:#e2e3e5
    style SKIP2 fill:#e2e3e5
    style SKIP3 fill:#e2e3e5
    style SKIP4 fill:#e2e3e5
```

---

## Schéma 6 : Timeline typique (durées moyennes)

```mermaid
gantt
    title Pipeline CI/CD - Timeline Typique
    dateFormat mm:ss
    axisFormat %M:%S

    section Setup
    Install Node + SF CLI    :00:00, 03:00
    Install Java             :03:00, 01:00
    Install Plugins          :04:00, 02:00

    section Auth
    Auth Salesforce          :06:00, 00:30
    Auth GitHub CLI          :06:30, 00:30

    section Delta
    Generate Delta Package   :07:00, 01:30
    Add Test Classes         :08:30, 00:30

    section Quality
    Run Code Analyzer        :09:00, 02:00
    Check & Upload SARIF     :11:00, 00:30

    section Flows
    Check Flows              :09:00, 00:15
    Scan Flows               :09:15, 01:30
    Format & Comment         :10:45, 00:45

    section Validation
    Deploy Check-only        :11:30, 08:30
```

**Légende des durées** :
- ⚡ Rapide : < 2 min
- ⏱️ Moyen : 2-5 min
- 🐢 Long : 5-30 min (dépend du nombre de tests)

---

## Récapitulatif des 6 phases

| Phase | Nom | Durée | Outils clés | Condition |
|-------|-----|-------|-------------|-----------|
| **1** | Setup | 5-8 min | Node, SF CLI, Java, Plugins | Toujours |
| **2** | Authentification | 1 min | SFDX URL, gh CLI | Toujours |
| **3** | Delta Generation | 2-5 min | sfdx-git-delta | Toujours |
| **4** | Analyse Qualité | 2-5 min | code-analyzer, jq | Toujours |
| **5** | Flow Validation | 1-3 min | flow-scanner, Python | Si flows détectés |
| **6** | SF Validation | 5-30 min | sf deploy, Apex tests | Toujours |

**Total** : 15-52 minutes (moyenne : 18 minutes)

---

## Points clés à retenir

### ✅ Optimisations implémentées
- **Delta deployment** : Seules les métadonnées modifiées sont validées
- **Upload SARIF conditionnel** : Évite les uploads inutiles si aucune issue
- **Flow scan conditionnel** : Skip si aucun flow modifié
- **Tests auto-inclusion** : Les classes de test sont ajoutées automatiquement
- **Commentaire éditable** : Un seul commentaire mis à jour au lieu de multiples

### 🎯 Sorties du pipeline
1. **Logs détaillés** → Onglet "Checks" de la PR
2. **Commentaire Flow** → Directement dans la PR
3. **Alertes Security** → Onglet Security du repo
4. **Statut final** → ✅ Success ou ❌ Failure

### ⚡ Performance
- Temps moyen : **15-20 minutes**
- Temps min : **10 minutes** (petit changement, peu de tests)
- Temps max : **30+ minutes** (gros changement, nombreux tests)

---

**Document créé le** : 2025-11-04
**Complément de** : PIPELINE_CI_DOCUMENTATION_CONFLUENCE.md
