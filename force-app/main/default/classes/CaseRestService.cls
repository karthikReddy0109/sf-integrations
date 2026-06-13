@RestResource(urlMapping = '/caseService/*')
global with sharing class CaseRestService {
    public class OpenCasesResponse{
        @AuraEnabled public String id;
        @AuraEnabled public String accountId;
        @AuraEnabled public String subject;
    }

    @HttpGet
    global static void getOpenCases(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> headers = req.headers;
        for(String key : headers.keySet()){
            System.debug(key + ' = ' + headers.get(key));
        }

        String token = req.headers.get('x-portal-token');
        System.debug('Token : ' + token);

        Portal_Config__c config = Portal_Config__c.getValues('Default');
        String expectedToken = config.Token__c;
        System.debug('Expected Token : ' + expectedToken);
        if(config == null || token != expectedToken){
            res.statusCode = 401;
            res.responseBody = Blob.valueOf('{"error" : "Unauthorized"}');
            return;
        }

        // 1. Read account id from query parameters
        String accountId = req.params.get('accountId');
        // 2. List all open cases for that Account
        List<Case> caseList = [
            SELECT Id, AccountId, Subject, Status, CaseNumber
            FROM Case
            WHERE AccountId =: accountId
            AND Status != 'Closed'
        ];
        // 3. Build response
        res.statusCode = 200;
        List<OpenCasesResponse> payload = new List<OpenCasesResponse>();
        for(Case cs : caseList){
            OpenCasesResponse payloadItem = new OpenCasesResponse();
            payloadItem.id = cs.Id;
            payloadItem.accountId = cs.AccountId;
            payloadItem.subject = cs.Subject;
            payload.add(payloadItem);
        }
        res.responseBody = Blob.valueOf(JSON.serialize(payload));
    }
}