/**
 * @description Data Access Layer pour les contacts
 */
public with sharing class ContactDataManager {
    
    /**
     * @description Récupère tous les contacts
     * @return List<Contact> Liste des contacts
     */
    public static List<Contact> getAllContacts() {
        return [
            SELECT Id, FirstName, LastName, Email, Phone, Title, Account.Name
            FROM Contact 
            WITH SECURITY_ENFORCED
            ORDER BY LastName ASC
            LIMIT 100
        ];
    }
}
