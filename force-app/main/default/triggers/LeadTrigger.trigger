trigger LeadTrigger on Lead (after insert) {
    LeadTriggerHandler.validateLeadCityForWeatherCondition(trigger.new);
}