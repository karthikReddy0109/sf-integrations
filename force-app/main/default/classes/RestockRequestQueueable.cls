public class RestockRequestQueueable implements Queueable, Database.AllowsCallouts {
    public class RestockRequestBody{
        public Id productId;
        public Integer quantityNeeded;
    }

    private Id productId;
    private Integer retryCount;
    public RestockRequestQueueable(Id productId, Integer retryCount) {
        this.productId = productId;
        this.retryCount = retryCount;
    }

    private void updateRestockStatus(){
        try{
            Product__c product = [
                SELECT Id, Restock_Status__c
                FROM Product__c
                WHERE Id =: productId
            ];
            product.Restock_Status__c = 'Requested';
            update product;
        }catch(Exception ex){
            System.debug('Exception occured while getting product : ' + ex.getMessage());
        }
    }

    private void logAPIResponseInSyncErrorLog(String body, Integer retryCount){
        try{
            Sync_Error_Log__c errorLog = new Sync_Error_Log__c();
            errorLog.Error_Message__c = body;
            errorLog.Retry_Count__c = retryCount;
            if(retryCount == 3){
                errorLog.Status__c = 'Failed';
            }
            update errorLog;
        }catch(Exception ex){
            System.debug('Error updating errorLog : ' + ex.getMessage());
        }
    }

    private void retryRestockRequest(Integer retryCount){
        System.enqueueJob(new RestockRequestQueueable(productId, retryCount));
    }

    public void execute(QueueableContext qc){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://webhook.site/34537738-a018-4ae7-bfb3-f460ad1f21e3');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        RestockRequestBody payload = new RestockRequestBody();
        payload.productId = productId;
        payload.quantityNeeded = 25;
        request.setBody(JSON.serialize(payload));
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200){
            System.debug('API call successful');
            updateRestockStatus();
        }else{
            System.debug('API Call failed');
            String responseBody = response.getBody();
            logAPIResponseInSyncErrorLog(responseBody, retryCount);
            if(retryCount < 3){
                retryRestockRequest(retryCount+1);
            }
        }
    }
}