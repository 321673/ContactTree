({
	init : function(component, event, helper) {
		helper.doInit(component, event);
	},

	find : function(component, event, helper) {		
		helper.doFind(component, event);		
	},
	handleChooseContact : function(component, event, helper) {
		component.set("v.sortedContacts", []);
		component.set("v.condition",'');				
		helper.doShowChild(component, event);		
	},
	clear :  function(component, event, helper) {
		component.set("v.sortedContacts", []);
		component.set("v.condition",'');
	},
	clearTree  :  function(component, event, helper) {
				
		component.set("v.hasNestedContact", false);
		component.set("v.hasContact", false);
	}
})