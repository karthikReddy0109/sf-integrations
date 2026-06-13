public with sharing class LeadTriggerHandler {
    public static void validateLeadCityForWeatherCondition(List<Lead> leadList){
        if(leadList.isEmpty()) return;
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead ld : leadList){
            if(!String.isBlank(ld.City)){
                leadIdSet.add(ld.Id);
            }
        }
        System.debug('Lead Size : ' + leadIdSet.Size());
        if(leadIdSet.isEmpty()) return;
        System.enqueueJob(new WeatherConditionQueueable(leadIdSet));
    }
}