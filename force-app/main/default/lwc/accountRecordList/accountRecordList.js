import { LightningElement, wire } from 'lwc';
import getAllAccounts from '@salesforce/apex/AccountController.getAllAccounts';

export default class AccountRecordList extends LightningElement {
    accounts;
    
    @wire(getAllAccounts)
    wiredAccounts({ error, data }) {
        
        // EsLint GlobalVariable High rule triggered by use of global variable without var
        notDeclaredVariable = 1;    // this will create a global variable and trigger the rule

        // IfElseStmtsMustUseBraces Medium (3) rule violation
        // https://pmd.github.io/pmd/pmd_rules_ecmascript_codestyle.html#ifelsestmtsmustusebraces
        if (data)
            this.accounts = data;
        else if (error)
            console.error('Erreur lors du chargement des comptes:', error);
        

        return;
        // UnreachableCode High(1) Rule violation
        // https://pmd.github.io/pmd/pmd_rules_ecmascript_codestyle.html#unreachablecode
        let x = 20;
    }
    
}