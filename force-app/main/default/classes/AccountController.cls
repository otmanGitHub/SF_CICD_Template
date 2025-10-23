/**
 * @description Controller pour les comptes
 */
public with sharing class AccountController {
    
    /**
     * @description Récupère tous les comptes pour les composants UI
     * @return List<Account> Liste des comptes
     */
    // Bad naming convention in method name to trigger PMD AnnotationsNamingConvention Medium rule 
    // https://pmd.github.io/pmd/pmd_rules_apex_codestyle.html#annotationsnamingconventions
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        // FieldNamingConventions high rule triggered by not following naming conventions for variables
        // https://pmd.github.io/pmd/pmd_rules_apex_codestyle.html#fieldnamingconventions
        List<Account> accountsList = AccountServiceManager.getAllAccounts();
        return accountsList;
    }
    /**
     * Cette méthode prend une liste d'Id en entrée et effectue une requête SOQL sur la table Account pour chaque Id fourni.
     * Elle ne retourne aucune valeur. Cette méthode est volontairement mal écrite pour servir d'exemple à corriger par une IA.
     *
     * @param accountIds Liste des Ids des comptes à requêter
     */
    public static void getAccountsByIds(List<Id> accountIds) {
        for (Id accId : accountIds) {
            List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :accId];
            // Traitement inutile, juste pour l'exemple
            System.debug('Compte trouvé: ' + accList);
        }
    }
}