public class AddressTriggerHelper {
    // Before Insert of the Address to check there is no more than one Primary address on the same type on the same related record
    public static void beforeInsert(List<Address__c> newList){
        try{
            Set<String> relatedRecordIdSet = new Set<String>();
			Map<String, Set<String>> addressByRelatedToIdMap = new Map<String, Set<String>>();
            for(Address__c add: newList){
                if(add.Primary__c == true){
                    relatedRecordIdSet.add(add.Related_To__c);
                    if(addressByRelatedToIdMap.containsKey(add.Related_To__c)){
                        addressByRelatedToIdMap.get(add.Related_To__c).addAll(add.Address_Type__c.split(';'));
                    }
                    else{
                        addressByRelatedToIdMap.put(add.Related_To__c, new Set<String>(add.Address_Type__c.split(';')));
                    }
                }
            }
            List<Address__c> addToUpdate = new List<Address__c>(); 
            for(Address__c add: [SELECT Id, Related_To__c, Address_Type__c FROM Address__c WHERE Related_To__c IN :relatedRecordIdSet AND Primary__c = true]){
                if(add.Address_Type__c != null){
                    if(addressByRelatedToIdMap.containsKey(add.Related_To__c)){
                        Set<String> newTypes = addressByRelatedToIdMap.get(add.Related_To__c);
                        List<String> addTypes = add.Address_Type__c.split(';');
                        Set<String> cloneNewTypes = (Set<String>) JSON.deserialize(JSON.serialize(newTypes), Set<String>.class );
                        cloneNewTypes.retainAll(addTypes);
                        if(!cloneNewTypes.isEmpty()){
                            for(String ty: cloneNewTypes){
                                Integer index = addTypes.indexOf(ty);
                                if(index != -1){
                                    addTypes.remove(index);
                                }
                            }
                            add.Address_Type__c = String.join(addTypes, ';');
                            if(addTypes.isEmpty()){
                                add.Primary__c = false;
                            }
                            addToUpdate.add(add);
                        }
                    }
                }
            }
            if(!addToUpdate.isEmpty()){
                update addToUpdate;
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // After Update of the Address to check there is no more than one Primary address on the same type on the same related record
    
    public static void afterUpdate(List<Address__c> newList, Map<Id, Address__c> oldMap){
        	Set<String> relatedRecordIdSet = new Set<String>();
        	Set<String> triggeredRecIdSet = new Set<String>();
			Map<String, Set<String>> addressByRelatedToIdMap = new Map<String, Set<String>>();
            for(Address__c add: newList){
                triggeredRecIdSet.add(add.Id);
                if(add.Primary__c == true && (!oldMap.get(add.Id).Primary__c || (add.Related_To__c != oldMap.get(add.Id).Related_To__c && add.Related_To__c != null) || (add.Address_Type__c != oldMap.get(add.Id).Address_Type__c && add.Address_Type__c != null ))){
                    relatedRecordIdSet.add(add.Related_To__c);
                    if(addressByRelatedToIdMap.containsKey(add.Related_To__c)){
                        addressByRelatedToIdMap.get(add.Related_To__c).addAll(add.Address_Type__c.split(';'));
                    }
                    else{
                        addressByRelatedToIdMap.put(add.Related_To__c, new Set<String>(add.Address_Type__c.split(';')));
                    }
                }
            }
            List<Address__c> addToUpdate = new List<Address__c>(); 
            Map<String, Set<String>> existingAddByRelatedToId = new Map<String, Set<String>>();
            for(Address__c add: [SELECT Id, Related_To__c, Address_Type__c FROM Address__c WHERE Related_To__c IN :relatedRecordIdSet AND Primary__c = true AND Address_Type__c != null AND Id NOT IN :triggeredRecIdSet]){
                if(addressByRelatedToIdMap.containsKey(add.Related_To__c)){
                    Set<String> newTypes = addressByRelatedToIdMap.get(add.Related_To__c);
                    List<String> addTypes = add.Address_Type__c.split(';');
                    Set<String> cloneNewTypes = (Set<String>) JSON.deserialize(JSON.serialize(newTypes), Set<String>.class );
                    cloneNewTypes.retainAll(addTypes);
                    if(!cloneNewTypes.isEmpty()){
                        for(String ty: cloneNewTypes){
                            Integer index = addTypes.indexOf(ty);
                            if(index != -1){
                                addTypes.remove(index);
                            }
                        }
                        add.Address_Type__c = String.join(addTypes, ';');
                        if(addTypes.isEmpty()){
                            add.Primary__c = false;
                        }
                        addToUpdate.add(add);
                    }
                }  
            }
            if(!addToUpdate.isEmpty()){
                update addToUpdate;
            }
    }
    
}