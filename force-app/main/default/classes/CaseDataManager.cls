/**
 * @description Data Access Layer pour les cas
 */
public with sharing class CaseDataManager {
    
    /**
     * @description Récupère tous les cas
     * @return List<Case> Liste des cas
     */
    public static List<Case> getAllCases() {
        return [
            SELECT Id, CaseNumber, Subject, Status, Priority, Account.Name, Contact.Name
            FROM Case 
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];
    }
}
