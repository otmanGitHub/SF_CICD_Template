/**
 * @description Service Layer pour les contacts
 */
public with sharing class ContactServiceManager {
    
    /**
     * @description Récupère tous les contacts
     * @return List<Contact> Liste des contacts
     */
    public static List<Contact> getAllContacts() {
        return ContactDataManager.getAllContacts();
    }
}
