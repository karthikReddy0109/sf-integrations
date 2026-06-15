public with sharing class ProductTriggerHandler {
    public static void checkIfProductRequireRestock(List<Product__c> products){
        for(Product__c product : products){
            if((product.Stock_Quantity__c < product.Restock_Threshold__c) && (product.Restock_Status__c != 'Requested' && product.Restock_Status__c != 'Fulfilled')){
                System.debug('Making Restock Request');
                System.enqueueJob(new RestockRequestQueueable(product.Id, 0));
            }
        }
    }
}