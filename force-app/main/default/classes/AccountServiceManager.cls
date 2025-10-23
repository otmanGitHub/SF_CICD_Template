/**
 * @description Service Layer pour les comptes
 * Gère la logique métier des comptes
 */
public with sharing class AccountServiceManager {
    
    /**
     * @description Récupère tous les comptes avec validation
     * @return List<Account> Liste des comptes
     */
    public static List<Account> getAllAccounts() {
        return AccountDataManager.getAllAccounts();
    }
}