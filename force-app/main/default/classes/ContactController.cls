/**
 * @description Controller pour les contacts
 */
public with sharing class ContactController {
    
    /**
     * @description Récupère tous les contacts pour les composants UI
     * @return List<Contact> Liste des contacts
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAllContacts() {
        return ContactServiceManager.getAllContacts();
    }
}
