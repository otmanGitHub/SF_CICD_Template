import { LightningElement, wire } from 'lwc';
import getAllCases from '@salesforce/apex/CaseController.getAllCases';

export default class CaseRecordList extends LightningElement {
    cases;
    
    @wire(getAllCases)
    wiredCases({ error, data }) {
        if (data) {
            this.cases = data;
        } else if (error) {
            console.error('Erreur lors du chargement des cases:', error);
        }
    }
}