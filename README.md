## Scenario — 1 
### Weather-Based Lead Follow-Up System
Your client is a real estate company. When a Lead is created with a City__c field filled in, they want to automatically fetch the current weather of that city from an external weather API and stamp it on a custom field Weather_Condition__c on the Lead.
The business logic is: if the weather condition is Rain or Storm, automatically set the Lead's Follow_Up_Priority__c to High — because people are more likely to be indoors and responsive to calls during bad weather.
    * Created a External Credential to define authentication
    * Created a Named Credential to define base URL
    * Salesforce will not allow you to make a synchronous callout. So always make  callouts in asynchronous ex: Queueable
    * create a trigger on lead 

    

