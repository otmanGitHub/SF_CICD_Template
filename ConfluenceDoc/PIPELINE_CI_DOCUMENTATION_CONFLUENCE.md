# Pipeline CI/CD Salesforce - Documentation Technique

---

## Table des matières

* Vue d'ensemble
* Prérequis et configuration
* Déclenchement du workflow
* Architecture et étapes détaillées
* Interprétation des résultats

---

## Vue d'ensemble

### Objectif du pipeline

Ce pipeline CI/CD automatise la validation des Pull Requests sur le projet Salesforce. Il permet de :

* Valider uniquement les métadonnées modifiées (déploiement delta)
* Analyser la qualité du code avec PMD et ESLint
* Scanner les flows avec Lightning Flow Scanner
* Exécuter les tests unitaires Apex
* Fournir un retour immédiat aux développeurs via commentaires GitHub

### Bénéfices clés

* **Qualité** : Détection précoce des bugs et violations de standards
* **Rapidité** : Validation uniquement des changements (delta), feedback en ~15 minutes
* **Transparence** : Résultats visibles directement dans la PR avec commentaires automatiques
* **Sécurité** : Analyse SARIF intégrée à GitHub Security

---

## Prérequis et configuration

### Infrastructure requise

**GitHub**
* Repository hébergé sur GitHub
* GitHub Actions activé
* Permissions : `security-events: write`, `pull-requests: write`, `contents: read`

**Salesforce**
* Org de validation/intégration configurée et accessible
* URL SFDX d'authentification générée
* Accès réseau : Le runner GitHub doit pouvoir atteindre Salesforce

### Configuration du secret GitHub

**Étape 1 : Obtenir l'URL SFDX**

Depuis votre terminal, connectez-vous à l'org de validation :

```bash
# Connexion à l'org
sf org login web --alias integration --instance-url https://test.salesforce.com

# Affichage de l'URL
sf org display --target-org integration --verbose --json
```

Cherchez dans la sortie JSON le champ `sfdxAuthUrl` qui commence par `force://PlatformCLI::`

**Étape 2 : Ajouter le secret dans GitHub**

1. Accédez à **Settings → Secrets and variables → Actions**
2. Cliquez sur **New repository secret**
3. Nom : `SFDX_INTEGRATION_URL`
4. Valeur : L'URL complète copiée précédemment
5. Cliquez sur **Add secret**

**Sécurité** : Ne jamais partager ou committer cette URL. La régénérer tous les 6 mois.

### Structure du repository

```
SF_CICD_Template/
├── .github/
│   ├── workflows/
│   │   └── automation-viseo-tma.yml      # Workflow principal
│   └── scripts/
│       └── format-flow-scan-results.py    # Script formatage Flow Scanner
├── force-app/
│   └── main/default/
│       ├── classes/                       # Classes Apex
│       ├── flows/                         # Flows
│       ├── lwc/                           # Lightning Web Components
│       └── objects/                       # Custom Objects
└── sfdx-project.json                      # Configuration SFDX
```

---

## Déclenchement du workflow

### Événements déclencheurs

Le workflow se déclenche automatiquement sur les événements suivants :

**À la création d'une Pull Request**
* Événement GitHub : `pull_request.opened`
* Valide l'ensemble des changements proposés

**À chaque nouveau commit sur une PR existante**
* Événement GitHub : `pull_request.synchronize`
* Re-valide avec les dernières modifications

### Filtres et conditions

**Filtre de chemin**

Le workflow s'exécute uniquement si des fichiers sont modifiés dans `force-app/**`

Si vous modifiez uniquement des fichiers hors de ce dossier (README, doc, etc.), le workflow ne se déclenche pas.

**Exclusions**

Le workflow est désactivé pour les Pull Requests créées par `dependabot[bot]`

---

## Architecture et étapes détaillées

### Vue d'ensemble des 6 phases

Le pipeline s'exécute en 6 phases séquentielles pour un total de 10-30 minutes :

**Phase 1 : Setup** (5-8 min)
* Installation de l'environnement d'exécution
* Installation des outils Salesforce et plugins

**Phase 2 : Authentification** (1 min)
* Connexion à l'org Salesforce
* Authentification GitHub

**Phase 3 : Génération du package delta** (2-5 min)
* Extraction des métadonnées modifiées
* Ajout automatique des tests

**Phase 4 : Analyse de qualité** (2-5 min)
* Scan PMD (Apex) et ESLint (JavaScript)
* Upload des résultats dans GitHub Security

**Phase 5 : Validation des Flows** (1-3 min)
* Scan des flows modifiés
* Publication d'un commentaire sur la PR

**Phase 6 : Validation Salesforce** (5-30 min)
* Déploiement check-only avec tests
* Vérification de la couverture de code

---

### Phase 1 : Installation et Setup

**Durée** : 5-8 minutes

**Objectif** : Préparer l'environnement d'exécution avec tous les outils nécessaires

**Étapes dans le YAML** :

1. **Installation Node.js version 22**
   ```yaml
   - name: installing node version
     uses: actions/setup-node@v5
     with:
       node-version: '22'
   ```
   * Fournit l'environnement d'exécution pour Salesforce CLI

2. **Checkout du code source**
   ```yaml
   - name: 'Checkout source code'
     uses: actions/checkout@v5
     with:
       fetch-depth: 0
   ```
   * `fetch-depth: 0` récupère tout l'historique Git (nécessaire pour la comparaison delta)

3. **Installation Salesforce CLI version 2.108.6**
   ```yaml
   - name: 'Install Salesforce CLI'
     run: |
       npm install -g @salesforce/cli@2.108.6
       sf version
   ```
   * Version fixée pour garantir la reproductibilité

4. **Installation Java (OpenJDK 21)**
   ```yaml
   - name: 'Installing JAVA with apt'
     run: |
       sudo apt-get update
       sudo apt install default-jdk
   ```
   * Requis pour PMD (outil d'analyse Apex écrit en Java)

5. **Installation des plugins Salesforce**
   ```yaml
   - name: 'Installing SF plugins'
     run: |
       echo y | sf plugins install @salesforce/plugin-code-analyzer@5.5.0
       echo y | sf plugins install sfdx-git-delta@6.22.0
       echo y | sf plugins install lightning-flow-scanner@5.7.2
       sf plugins
   ```

Plugins installés :
* `code-analyzer v5.5.0` : Analyse statique du code (PMD, ESLint)
* `sfdx-git-delta v6.22.0` : Génération des packages delta
* `lightning-flow-scanner v5.7.2` : Validation des flows

---

### Phase 2 : Authentification

**Durée** : 1 minute

**Objectif** : Établir les connexions nécessaires à Salesforce et GitHub

**Étapes dans le YAML** :

1. **Chargement du secret SFDX**
   ```yaml
   - name: 'Populate auth file with SFDX_URL secret'
     run: |
       echo ${{ secrets.SFDX_INTEGRATION_URL}} > ./SFDX_INTEGRATION_URL.txt
   ```
   * Le secret est écrit dans un fichier temporaire

2. **Authentification Salesforce**
   ```yaml
   - name: 'Authenticate to Integration Org'
     run: sf org login sfdx-url --sfdx-url-file ./SFDX_INTEGRATION_URL.txt --set-default --alias integration
   ```
   * Connexion non-interactive via le protocole SFDX URL
   * L'org est enregistrée avec l'alias `integration`

3. **Authentification GitHub CLI**
   ```yaml
   - name: 'Authenticate gh client'
     run: echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token
   ```
   * `GITHUB_TOKEN` est fourni automatiquement par GitHub Actions
   * Permet de poster des commentaires sur la PR

---

### Phase 3 : Génération du package delta

**Durée** : 2-5 minutes

**Objectif** : Identifier et extraire uniquement les métadonnées modifiées

**Étapes dans le YAML** :

1. **Création du package delta**
   ```yaml
   - name: 'Create delta packages'
     run: |
       mkdir changed-sources
       sf sgd source delta --to "HEAD" --from "${{github.event.pull_request.base.sha}}" \
         --output-dir changed-sources/ --generate-delta --source-dir force-app/
   ```

Fonctionnement :
* Compare le SHA du HEAD de la PR avec le SHA de la branche cible
* Extrait uniquement les fichiers ajoutés/modifiés/supprimés
* Génère un package XML dans le dossier `changed-sources/`

Exemple : Si vous modifiez seulement `AccountController.cls`, le package delta contiendra uniquement ce fichier.

2. **Ajout automatique des classes de test**
   ```yaml
   - name: 'Add modified apex test classes'
     run: |
       for file in changed-sources/force-app/main/default/classes/*.cls; do
         base_name=$(basename "$file" .cls)
         if [[ ! "$base_name" =~ Test$ ]]; then
           test_class="force-app/main/default/classes/${base_name}Test.cls"
           test_meta="force-app/main/default/classes/${base_name}Test.cls-meta.xml"
           if [ -f "$test_class" ]; then
             cp "$test_class" changed-sources/force-app/main/default/classes/
             cp "$test_meta" changed-sources/force-app/main/default/classes/
           fi
         fi
       done
   ```

Logique :
* Pour chaque classe Apex modifiée (ex: `AccountController.cls`)
* Cherche la classe de test correspondante (`AccountControllerTest.cls`)
* Si trouvée, l'ajoute automatiquement au package
* Garantit que les tests seront exécutés lors de la validation

---

### Phase 4 : Analyse de qualité du code

**Durée** : 2-5 minutes

**Objectif** : Détecter les bugs potentiels et violations de standards

**Étapes dans le YAML** :

1. **Exécution du code analyzer**
   ```yaml
   - name: '@Salesforce/plugin-code-analyzer'
     run: |
       sf code-analyzer run --rule-selector pmd --rule-selector eslint \
         --target 'changed-sources/**/*' --output-file 'pmdScanResults.sarif.json'
   ```

Moteurs utilisés :
* **PMD** (Apex) : Détecte bugs, conventions de nommage, code dupliqué, complexité
* **ESLint** (JavaScript/LWC) : Vérifie syntaxe, standards de codage, erreurs courantes

Format de sortie : SARIF (Static Analysis Results Interchange Format)

2. **Vérification du fichier SARIF**
   ```yaml
   - name: 'Check SARIF file'
     id: setUploadSarif
     run: |
       if jq -e '.runs | length == 0' pmdScanResults.sarif.json > /dev/null; then
         echo "uploadSarif=false" >> $GITHUB_OUTPUT
       else
         echo "uploadSarif=true" >> $GITHUB_OUTPUT
       fi
   ```

* Utilise `jq -e` pour vérifier si le tableau `.runs` est vide
* L'option `-e` fait que jq retourne exit code 0 si true, 1 si false
* Si vide (aucune issue) → pas d'upload
* Si contient des issues → upload vers GitHub Security

3. **Upload vers GitHub Security**
   ```yaml
   - name: Upload SARIF file
     if: steps.setUploadSarif.outputs.uploadSarif == 'true'
     uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: pmdScanResults.sarif.json
   ```

* Condition : Exécuté uniquement si le SARIF contient des issues
* Les résultats apparaissent dans **Security → Code scanning alerts**

---

### Phase 5 : Validation des Flows

**Durée** : 1-3 minutes

**Objectif** : Garantir la qualité et la maintenabilité des flows Salesforce

**Étapes dans le YAML** :

1. **Vérification de l'existence de flows**
   ```yaml
   - name: 'Check for modified flows'
     id: checkFlows
     run: |
       if [ -d "changed-sources/force-app/main/default/flows" ] && [ "$(ls -A changed-sources/force-app/main/default/flows)" ]; then
         echo "flows_exist=true" >> $GITHUB_OUTPUT
       else
         echo "flows_exist=false" >> $GITHUB_OUTPUT
       fi
   ```

* Vérifie si le dossier flows existe ET contient des fichiers
* Définit une variable `flows_exist` utilisée dans les étapes suivantes

2. **Exécution du Flow Scanner**
   ```yaml
   - name: 'Run Flow Scanner on changed flows'
     if: steps.checkFlows.outputs.flows_exist == 'true'
     run: |
       sf flow:scan --directory changed-sources/force-app/main/default/flows > lightning-flow-scan_ansiResult.txt || true
       sed 's/\x1b\[[0-9;]*m//g' lightning-flow-scan_ansiResult.txt > lightning-flow-scan_result_cleanResult.txt
   ```

* Exécuté seulement si des flows sont détectés
* `|| true` évite que l'échec du scan ne fasse échouer le workflow
* `sed` retire les codes couleur ANSI pour faciliter le parsing

Règles validées :
* Missing Flow Description
* Missing Fault Path (gestion d'erreurs)
* DML/SOQL in loops
* Hardcoded IDs/URLs
* Duplicate DML operations

3. **Formatage des résultats**
   ```yaml
   - name: 'Format Flow Scanner results'
     if: steps.checkFlows.outputs.flows_exist == 'true'
     run: |
       python3 .github/scripts/format-flow-scan-results.py \
         lightning-flow-scan_result_cleanResult.txt flow-scan-comment.md
   ```

Le script Python :
* Parse les résultats bruts du scanner
* Génère un tableau Markdown structuré
* Catégorise par sévérité (🔴 error, 🟡 warning, 🔵 note)
* Calcule un résumé global avec compteurs
* Possède un fallback automatique si le summary est incomplet

4. **Publication du commentaire sur la PR**
   ```yaml
   - name: 'Comment flow scan result on PR'
     if: steps.checkFlows.outputs.flows_exist == 'true'
     run: |
       gh pr comment ${{ github.event.pull_request.number }} --edit-last --body-file flow-scan-comment.md || \
       gh pr comment ${{ github.event.pull_request.number }} --body-file flow-scan-comment.md
   ```

* Tente d'abord de modifier le dernier commentaire (`--edit-last`)
* Si aucun commentaire existant, en crée un nouveau
* Évite de spammer la PR avec plusieurs commentaires

---

### Phase 6 : Validation Salesforce

**Durée** : 5-30 minutes (variable selon la taille)

**Objectif** : Valider que le déploiement fonctionnera en production

**Étape dans le YAML** :

```yaml
- name: 'Check conf and tests on changed sources folder'
  run: |
    sf project deploy start --source-dir changed-sources/force-app \
      --dry-run --test-level RunLocalTests
```

**Paramètres** :

* `--source-dir changed-sources/force-app` : Déploie uniquement les métadonnées du delta
* `--dry-run` : Mode validation (aucune modification de l'org)
* `--test-level RunLocalTests` : Exécute tous les tests locaux du package
* Timeout par défaut : 33 minutes

**Comportement** :

Le workflow **attend activement** la fin de la validation :
* Salesforce simule le déploiement complet
* Les tests sont réellement exécutés
* La couverture de code est calculée (minimum 75% requis)
* En cas d'échec (tests KO, erreur compilation), le job échoue
* En cas de succès, le job se termine avec statut ✅

**⚠️ Important** : Ce temps d'attente consomme des minutes GitHub Actions. Pour un repository privé avec plan gratuit (2000 min/mois), une validation de 15 minutes consomme 15 minutes du quota.

---

## Interprétation des résultats

### Statuts possibles

**✅ Success (Succès)**
* Tous les checks sont passés
* La PR peut être mergée en toute sécurité
* Tests au vert avec couverture suffisante

**❌ Failure (Échec)**
* Au moins un check a échoué
* Corrections nécessaires avant le merge
* Causes possibles : tests KO, erreur compilation, violation PMD, couverture insuffisante

**🔄 In Progress (En cours)**
* Le workflow est en cours d'exécution
* Durée moyenne : 10-20 minutes

**⏭️ Skipped (Ignoré)**
* Le workflow n'a pas été exécuté
* Pas de modification dans `force-app/`

### Où trouver les résultats

**1. Onglet "Checks" de la Pull Request**

Localisation : Directement dans la PR GitHub

* Statut global du workflow (✅ ou ❌)
* Détail de chaque étape avec logs
* Messages d'erreur détaillés en cas d'échec
* Cliquez sur "Details" pour explorer les logs

**2. Commentaire Flow Scanner**

Localisation : Dans les commentaires de la PR

* Nombre de flows scannés
* Liste des violations par flow avec tableau détaillé
* Résumé par sévérité (errors/warnings/notes)
* Mis à jour automatiquement à chaque commit

**3. Onglet "Security" du repository**

Localisation : `Security → Code scanning alerts`

* Issues PMD et ESLint détectées
* Filtres par sévérité, fichier, règle
* Historique des issues
* Possibilité de marquer comme résolu

---

## Résumé du flux complet

1. **Développeur crée/met à jour une PR** → Le workflow se déclenche automatiquement
2. **Setup** → Installation de l'environnement et des outils (Node, SF CLI, Java, plugins)
3. **Authentification** → Connexion à Salesforce et GitHub
4. **Delta** → Extraction des métadonnées modifiées + ajout des tests
5. **Analyse** → Scan PMD/ESLint avec upload SARIF conditionnel
6. **Flows** → Scan des flows (si présents) avec commentaire sur la PR
7. **Validation SF** → Déploiement check-only avec tests et vérification couverture
8. **Résultat** → ✅ Succès → merge autorisé | ❌ Échec → corrections requises

**Durée totale moyenne** : 10-20 minutes

**Quota consommé** : Temps réel d'exécution du workflow

---

**Dernière mise à jour** : 2025-11-03
**Version** : 1.0
**Équipe** : DevOps Salesforce
