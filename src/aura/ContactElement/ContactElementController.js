({
	chooseContact : function(component, event, helper) {
		var chooseContactEvent = component.getEvent("ChooseContact");
				chooseContactEvent.setParams({
					"contact": component.get("v.contact"),					
				});
				chooseContactEvent.fire();
	},
})