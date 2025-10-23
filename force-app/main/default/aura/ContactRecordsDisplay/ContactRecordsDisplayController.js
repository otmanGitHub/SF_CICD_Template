({
    doInit: function(component, event, helper) {
        var action = component.get("c.getAllContacts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contacts", response.getReturnValue());
            } else {
                console.error("Erreur lors du chargement des contacts");
            }
        });
        $A.enqueueAction(action);
    }
})