/**
 * @description Service Layer pour les cas
 */
public with sharing class CaseServiceManager {
    
    /**
     * @description Récupère tous les cas
     * @return List<Case> Liste des cas
     */
    public static List<Case> getAllCases() {
        return CaseDataManager.getAllCases();
    }
}
