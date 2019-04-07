public with sharing class NewChiledContactTriggerHandler extends TriggerHandler{

	Map<Id,sObject> oldContacts = Trigger.OldMap;
	Map<Id,sObject> newContacts = Trigger.NewMap;

	public override void afterInsert(){
		if(insertedContactsWithNotNullParentField().size()>0){
		changedParent(
			insertedContactsWithNotNullParentField(), 
			new Map<id,Contact>(), 
			newParents(setIds(insertedContactsWithNotNullParentField()))
			);
		}	
	}                                     

	public override void afterUpdate() {   
	if(updatedContactsWithChangedParentFieldList().size()>0){
		changedParent(
			updatedContactsWithChangedParentFieldList(), 
			oldParents(setIds(updatedContactsWithChangedParentFieldList())), 
			newParents(setIds(updatedContactsWithChangedParentFieldList()))
			);
		}
		if(updatedContactsWithChangedChiledField().size()>0){
			moveChiled(
				updatedContactsWithChangedChiledField(),
				newParents(setIds(updatedContactsWithChangedChiledField()))
			);
		}    
	}

	private List<Contact> insertedContactsWithNotNullParentField (){
		List<Contact> insertedContactsWithNotNullParentFieldList = new List<Contact>();
		for(ID id : newContacts.keySet()){
			Contact newContact = (Contact)newContacts.get(id);
			if(newContact.Parent_Contact__c != null){
				insertedContactsWithNotNullParentFieldList.add(newContact);
			}   
		}
		return insertedContactsWithNotNullParentFieldList;
	}

	private List<Contact> updatedContactsWithChangedParentFieldList (){
		List<Contact> updatedContactsWithChangedParentFildsList = new List<Contact>();
		for(ID id : newContacts.keySet()){
			Contact newContact = (Contact)newContacts.get(id);
			Contact oldContact = (Contact)oldContacts.get(id);
			
			if((newContact.Parent_Contact__c != oldContact.Parent_Contact__c)){
				updatedContactsWithChangedParentFildsList.add(newContact);
			}   
		}
		return updatedContactsWithChangedParentFildsList;
	}

	private List<Contact> updatedContactsWithChangedChiledField (){
		List<Contact> updatedContactsWithChangedChiledList = new List<Contact>();
		for(ID id : newContacts.keySet()){
			Contact newContact = (Contact)newContacts.get(id);
			Contact oldContact = (Contact)oldContacts.get(id);
			if((newContact.Child_Contacts__c != oldContact.Child_Contacts__c)){
				updatedContactsWithChangedChiledList.add(newContact);
			}   
		} 
		return updatedContactsWithChangedChiledList;
	}

	private Set<Id> setIds (List<Contact> contacts){	
		Set<Id> setId = new Set<Id>();
		for(Contact cont: contacts){
			setId.add(cont.Id);
		}  
		return setId;
	}

	private Map<Id,Contact> oldParents(Set<ID> updatedContactsWithChangedParentFildSet){		
		Map<Id,Id> oldParentIdMap = new Map<Id,Id>();
		for(Id updatedContactsWithChangedParentFildIs : updatedContactsWithChangedParentFildSet){
			Contact oldContact = (Contact)oldContacts.get(updatedContactsWithChangedParentFildIs);
			oldParentIdMap.put(updatedContactsWithChangedParentFildIs, oldContact.Parent_Contact__c);
		}
		Map <Id,Contact> contactsWithOldParentMap = new Map <Id,Contact>();
		contactsWithOldParentMap.putAll([SELECT ID, Child_Contacts__c, Parent_Contact__c, Parent_Contact__r.Child_Contacts__c, Name FROM Contact WHERE ID IN :oldParentIdMap.values()]);	
		Map <Id,Contact> contactsWithChildIdAndOldParentMap = new Map <Id,Contact>();
		for(Id ids : oldParentIdMap.KeySet()){
			Id valueOfOldParentMapThatIsKeyInContactsWithOldParentMap = oldParentIdMap.get(ids);
			Contact contactFromContactsWithOldParentMap = contactsWithOldParentMap.get(valueOfOldParentMapThatIsKeyInContactsWithOldParentMap);
			contactsWithChildIdAndOldParentMap.put(ids,contactFromContactsWithOldParentMap);
		}		
		return contactsWithChildIdAndOldParentMap;
	}



	private Map<Id,Contact> newParents(Set<ID> updatedContactsWithChangedParentFildSet){
			
		Map<Id,Id> newParentIdMap = new Map<Id,Id>();
		for(Id updatedContactsWithChangedParentFildIs : updatedContactsWithChangedParentFildSet){
			Contact newContact = (Contact)newContacts.get(updatedContactsWithChangedParentFildIs);
			newParentIdMap.put(updatedContactsWithChangedParentFildIs, newContact.Parent_Contact__c);
		}
		Map <Id,Contact> contactsWithNewParentMap = new Map <Id,Contact>();
		contactsWithNewParentMap.putAll([SELECT ID, Child_Contacts__c, Parent_Contact__c, Parent_Contact__r.Child_Contacts__c, Name FROM Contact WHERE ID IN :newParentIdMap.values()]);	
		Map <Id,Contact> contactsWithChildIdAndNewParentMap = new Map <Id,Contact>();
		for(Id ids : newParentIdMap.KeySet()){
			Id valueOfOldParentMapThatIsKeyInContactsWithNewParentMap = newParentIdMap.get(ids);
			Contact contactFromContactsWithNewParentMap = contactsWithNewParentMap.get(valueOfOldParentMapThatIsKeyInContactsWithNewParentMap);
			contactsWithChildIdAndNewParentMap.put(ids,contactFromContactsWithNewParentMap);
		}
		return contactsWithChildIdAndNewParentMap;
	}



	private void changedParent (List<Contact> updatedContactsWithChangedParentFildsList, Map <Id,Contact> contactsWithChildIdAndOldParentMap, Map <Id,Contact> contactsWithChildIdAndNewParentMap){
		List<Contact> newPreparedContacts = new List<Contact>();
		for(Contact contact : updatedContactsWithChangedParentFildsList){		
			Contact oldParent = contactsWithChildIdAndOldParentMap.get(contact.id);
			if(oldParent!=null){
				Decimal oldParentChilds = oldParent.Child_Contacts__c;
				Contact oldContact = (Contact)oldContacts.get(contact.id);
				Decimal oldContactChild = oldContact.Child_Contacts__c;		
				if(oldContactChild==null){
					oldContactChild=0;
				}		
				newPreparedContacts.add( new Contact ( Id = oldParent.Id, Child_Contacts__c = oldParentChilds - oldContactChild - 1));		
			}		
			Contact newParent = contactsWithChildIdAndNewParentMap.get(contact.id);
			if(newParent!=null){
				Decimal newParentChild = newParent.Child_Contacts__c;
				Contact newContact = (Contact)newContacts.get(contact.id);
				Decimal newContactChild = newContact.Child_Contacts__c;
				if(newParentChild==null){
					newParentChild = 0;
				}
				if(newContactChild==null){
					newContactChild=0;
				}			
				newPreparedContacts.add( new Contact (Id = newParent.Id, Child_Contacts__c = newParentChild + newContactChild + 1));
			}
		}
		update newPreparedContacts;
	}

	private void moveChiled(List<Contact> updatedContactsWithChangedParentFildsList, Map<Id,Contact> contactsWithChildIdAndNewParentMap){
		List<Contact> newPreparedContacts = new List<Contact>();
		for(Contact contact : updatedContactsWithChangedParentFildsList){
			if(contact.Parent_Contact__c!=null){
				Contact newParentContact = contactsWithChildIdAndNewParentMap.get(contact.id);
				Decimal newParentContactChild = newParentContact.Child_Contacts__c;
				Contact newContact = (Contact)newContacts.get(contact.id);
				Decimal newContactChild = newContact.Child_Contacts__c;				
				Contact oldContact = (Contact)oldContacts.get(contact.id);
				Decimal oldContactChild = oldContact.Child_Contacts__c;
				if(oldContactChild==null){
					oldContactChild=0;
				}
				if(newContactChild==null){
					newContactChild=0;
				}
				if(newParentContactChild==null){
					newParentContactChild=0;
				}
				newPreparedContacts.add(new Contact (
					Id = contact.Parent_Contact__c,
					Child_Contacts__c = newParentContactChild-oldContactChild+newContactChild
					));				
			}
		}
		update newPreparedContacts;
	}
}