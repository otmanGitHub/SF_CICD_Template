/**
 * @description Controller pour les cas
 */
public with sharing class CaseController {
    
    /**
     * @description Récupère tous les cas pour les composants UI
     * @return List<Case> Liste des cas
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCases() {
        return CaseServiceManager.getAllCases(); ceci est un commentaire sans balise commentaire
    }
}
