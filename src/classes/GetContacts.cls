public class GetContacts {
    
/* 
Create new custom field "Parent Contact" with Lookup type on Contact object. 
Create new custom field "Child Contacts" with Number type on Contact object.
Implement functionality to calculate number of child contacts for every contact. 
I.e. if some contact has 2 child contacts and these child contacts has 2 more child contacts each then parent contact should have 6 in the "Child Contacts" field.
The functionality should allow mass updates
 */
    
    public static Map<Id,Integer> nestedContacts = new Map<Id,Integer>();
    private static Integer incapsulationLevel =0;
    public static List<NestedContact>  nestedContactsList = new List<NestedContact>();
    //used for another logic
    @AuraEnabled
    public static List<sObject> querySalesforceRecord(String queryString) {        
        String newSearchText = '\'%' +String.escapeSingleQuotes(queryString) + '%\'';        
        String query = 'SELECT Id, Name, Email, Child_Contacts__c, Parent_Contact__r.Name FROM Contact WHERE (Name LIKE ' + newSearchText + ')';
        return Database.query(query);
    }

    @AuraEnabled
    public static List<Contact> getAllContacts(){
        return [SELECT Id, Name, Child_Contacts__c, Parent_Contact__r.Name FROM Contact LIMIT 50000];
    }
    
    @AuraEnabled
    public static List<NestedContact> getIncapsulatedContacts(String rootContactId){
        if(rootContactId!=null){
        	incapsulatedContacts(rootContactId);
            sortNestedContact();             
       		return nestedContactsList;
   		 }    	
        return null;        
    }
    
    private static void sortNestedContact(){
        Integer max = nestedContactsList[0].incapsulationLevel;
        for(Integer i = 0; i<nestedContactsList.size(); i++){               
            for(Integer j=0; j<nestedContactsList.size(); j++){
                if(nestedContactsList[j].incapsulationLevel>nestedContactsList[i].incapsulationLevel){
                    max = nestedContactsList[j].incapsulationLevel;
                    NestedContact tempNc  = nestedContactsList[i];
                    nestedContactsList[i] = nestedContactsList[j];
                    nestedContactsList[j] = tempNc;
                }
            }               
        }            
    }

    private static void incapsulatedContacts(String rootContactId){      
      for(Contact contact:getChild(rootContactId)){
        incapsulationLevel++;
        nestedContacts.put(contact.Id,incapsulationLevel);
        nestedContactsList.add(new NestedContact(contact,incapsulationLevel));         
        if(contact.Child_Contacts__c>0){                
            incapsulatedContacts(contact.Id);                 
        }
        incapsulationLevel--;        
      }        
    }

    private  static List<Contact> getChild (String parentId){
        return [SELECT Id, Name, Child_Contacts__c FROM Contact WHERE Parent_Contact__c =: parentId];
    }

    public class NestedContact{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Integer incapsulationLevel {get;set;}
        @AuraEnabled public Id id{get;set;}
        
        public NestedContact(Contact contact, Integer incapsulationLevel){
            this.name = contact.Name;
            this.id = contact.Id;
            this.incapsulationLevel = incapsulationLevel;
        }
    }
}