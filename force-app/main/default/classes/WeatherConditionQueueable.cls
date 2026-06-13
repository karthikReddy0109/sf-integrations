public class WeatherConditionQueueable implements Queueable, Database.AllowsCallouts{

    public class WeatherResponse {
        public List<CurrentCondition> current_condition;
    }

    public class CurrentCondition {
        public String temp_C;
        public String humidity;
        public List<WeatherDesc> weatherDesc;
    }

    public class WeatherDesc {
        public String value;
    }

    Set<Id> leadIdSet = new Set<Id>();
    public WeatherConditionQueueable(Set<Id> leadIdSet) {
        this.leadIdSet = leadIdSet;
    }

    private static String getWeatherConditionForCity(Lead ld){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String city = ld.City;
        req.setEndpoint('callout:Weather_API_Named_Credential/' + EncodingUtil.urlEncode(city, 'UTF-8') + '?format=j1');
        req.setMethod('GET');
        HttpResponse response = Http.send(req);
        String condition = '';
        if(response.getStatusCode() == 200){
            System.debug('API call success');
            System.debug('Retrieving weather condition');
            WeatherResponse weather = (WeatherResponse)JSON.deserialize(response.getBody(), WeatherResponse.class);
            if(
                weather != null && weather.current_condition != null && 
                !(weather.current_condition.isEmpty()) && weather.current_condition[0].weatherDesc != null &&
                !weather.current_condition[0].weatherDesc.isEmpty()
            ){
                condition = weather.current_condition[0].weatherDesc[0].value;
                System.debug('Condition : ' + condition);
            }
        }else{
            System.debug('API call failed: ' + response.getBody());
        }
        return condition;
    }
    
    public void execute(QueueableContext qc){
        // Retrieve lead records
        List<Lead> leadList = [
            SELECT Id,
            City 
            FROM Lead
            WHERE Id IN: leadIdSet
        ];
        if(leadList.isEmpty()) return;
        // Create a new lead list to update
        List<Lead> leadsToUpdate = new List<Lead>();
        //Iterate over leads
        for(Lead ld : leadList){
            String condition = getWeatherConditionForCity(ld);
            Lead lead = new Lead(Id = ld.Id, Weather_Condition__c = condition);
            leadsToUpdate.add(lead);
        }
        
        update leadsToUpdate;
    }
}