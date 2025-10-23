/**
 * @description Data Access Layer pour les comptes
 */
public with sharing class AccountDataManager {
    
    /**
     * @description Récupère tous les comptes
     * @return List<Account> Liste des comptes
     */
    public static List<Account> getAllAccounts() {
        return [
            SELECT Id, Name, Type, Industry, Phone, BillingCity
            FROM Account 
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT 100
        ];
    }
}