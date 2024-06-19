trigger AddressTrigger on Address__c (before insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        AddressTriggerHelper.beforeInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        AddressTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}