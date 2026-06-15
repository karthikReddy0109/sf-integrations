## Scenario — 1 
### Weather-Based Lead Follow-Up System
Your client is a real estate company. When a Lead is created with a City__c field filled in, they want to automatically fetch the current weather of that city from an external weather API and stamp it on a custom field Weather_Condition__c on the Lead.
The business logic is: if the weather condition is Rain or Storm, automatically set the Lead's Follow_Up_Priority__c to High — because people are more likely to be indoors and responsive to calls during bad weather.

* Created a External Credential to define authentication
* Created a Named Credential to define base URL
* Salesforce will not allow you to make a synchronous callout. So always make  callouts in asynchronous ex: Queueable
* create a trigger on lead 

## Scenario - 2
### Expose Salesforce Data to an External Portal
Your client has an external customer portal built in React. The portal needs to fetch a list of open Cases for a given Account directly from Salesforce via a REST API — without logging into Salesforce.
Build a custom inbound REST API using @RestResource that:

Accepts an Account Id as a URL parameter
Returns all open Cases under that Account with fields: Id, Subject, Status, Priority, CreatedDate
Returns proper HTTP status codes — 200 for success, 404 if Account not found, 500 for unexpected errors
Handles the response in JSON format

Extend it: The external portal sends a custom header X-Portal-Token with every request. Your Apex should validate this token against a value stored in a Custom Setting — if it does not match, return a 401 Unauthorized response.
    
* Built a global class CaseRestService
* Written a method getOpenCases annotated with **@HttpGet**
* When an external system calls your endpoint, salesforce gives you 2 objects via RestContext
* RestRequest contains all headers
* RestResponse - used to send response

## Scenario - 3
### Bidirectional Sync with an External Inventory System

Your client sells products and manages inventory in an external system. Whenever a product's Stock_Quantity__c falls below a threshold in Salesforce, it should automatically trigger a restock request to the external inventory system via a REST callout.
When the external system processes the restock, it calls back into Salesforce via your inbound REST API to update the Stock_Quantity__c and set Restock_Status__c to Fulfilled.
Build both sides:

Outbound — Trigger on Product__c detects low stock → Queueable callout → POST to external system
Inbound — @RestResource endpoint that accepts the callback and updates the Product record

Extend it: If the outbound callout fails, log the failure in a Sync_Error_Log__c object and retry up to 3 times using a Queueable chain. Track the retry count on the log record.

* Created a Trigger on Product object
* Created a ProductTriggerHandler class. The method **checkIfProductRequireRestock**  calls Queueable class(RestockRequestQueueable) when stock quantity goes below Restock threshold and 
