({
    doInit: function(component, event, helper) {
        var action = component.get("c.getAllCases");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
            } else {
                console.error("Erreur lors du chargement des cases");
            }
        });
        $A.enqueueAction(action);
    }
})