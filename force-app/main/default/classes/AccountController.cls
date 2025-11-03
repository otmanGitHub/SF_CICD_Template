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
    
}