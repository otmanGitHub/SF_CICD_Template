import { LightningElement, wire } from 'lwc';
import getAllContacts from '@salesforce/apex/ContactController.getAllContacts';

export default class ContactRecordList extends LightningElement {
    contacts;
    
    @wire(getAllContacts)
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
        } else if (error) {
            console.error('Erreur lors du chargement des contacts:', error);
        }
    }
}