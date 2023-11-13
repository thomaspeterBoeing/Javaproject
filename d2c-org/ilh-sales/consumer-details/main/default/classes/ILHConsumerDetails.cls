public with sharing class ILHConsumerDetails {
    @AuraEnabled(cacheable = true)
    public static String getPersonAccount(String recordId) {
        
        Opportunity oppy=[select accountId from Opportunity where id =:recordId];
        return oppy.accountId;
    }
}