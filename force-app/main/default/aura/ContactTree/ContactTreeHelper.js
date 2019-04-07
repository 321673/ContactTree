({
	CONTACTS:[],

	doInit : function(component, event) {
		var self = this;
		var action = component.get("c.getAllContacts");
		action.setCallback(this, function(response) {
		var state = response.getState();
		if (state === "SUCCESS") {
			var result = response.getReturnValue();			
			self.CONTACTS = result;					
		} else if (state === "INCOMPLETE") {
		} else if (state === "ERROR") {
		}
		});
		$A.enqueueAction(action);
	},

	doFind : function (component, event){		
		try{
			var self = this;
			var contacts = Object.values(self.CONTACTS);
			var result = [];
			var condition = component.get("v.condition").toLowerCase();
			if (condition === 'all'){
				component.set("v.sortedContacts",contacts);
				return
			}
			if (contacts.length>0 && condition.length>1 && condition != 'all') {
				result = contacts.filter(function(contact, index){
				return	(contact.Name.toLowerCase().indexOf(condition) > -1) || (contact.Email!=undefined && contact.Email.toLowerCase().indexOf(condition) > -1);
				});
			}
			component.set("v.sortedContacts",result);
		}catch(e){
			console.log('exception = ' + e);
		}
	},	

	doShowChild : function(component, event, helper) {
		var contact = event.getParams().contact;		
		component.set("v.contact", contact); 		
		component.set("v.hasContact", true);
		var action = component.get("c.getIncapsulatedContacts"); 
			action.setParams({rootContactId : contact.Id});
			action.setCallback(this, function(response) {
				  var state = response.getState();
				  if (state === "SUCCESS") {					          
					  component.set("v.nestedObjectList", response.getReturnValue());
					  component.set("v.hasNestedContact", true);					  
				  } 
			});           
			  $A.enqueueAction(action);
	   },

	isValid: function(param) {
		if (!$A.util.isUndefined(param) && !$A.util.isEmpty(param) && param !== null) {
			return true;
		}
		return false;
	},

})