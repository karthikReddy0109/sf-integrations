trigger ProductTrigger on Product__c (after update) {
    if(trigger.isAfter){
        if(trigger.isUpdate){
            ProductTriggerHandler.checkIfProductRequireRestock(trigger.new);
        }
    }
}