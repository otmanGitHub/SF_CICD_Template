({
    doInit: function(component, event, helper) {
        // EsLint GlobalVariable High rule triggered by use of global variable without var GlobalVariable 
        // https://pmd.github.io/pmd/pmd_rules_ecmascript_bestpractices.html#globalvariable
        notDeclaredVariable = 1;    // this will create a global variable and trigger the rule
        var action = component.get("c.getAllAccounts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accounts", response.getReturnValue());
            } else {
                console.error("Erreur lors du chargement des comptes");
            }
        });
        $A.enqueueAction(action);
        // ESLint disallow the use of no-console Rule violation https://denar90.github.io/eslint.github.io/docs/rules/no-console
        console.log('Initialization complete');
    }
})