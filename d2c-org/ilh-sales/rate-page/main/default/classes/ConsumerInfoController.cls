/**
 * Copyright: TruStage
 * Purpose: APEX controller for iLHSalesConsumerInfo LWC
 */
public with sharing class ConsumerInfoController {
    /***
     * Purpose: This method queries an opportunity based on id.
     * @param kvpSearchCriteria -- Opportunity id to query
     * @return Queried opportunity
     */
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityFieldsData(String opportunityId) {
        Opportunity opp = new Opportunity();

        try {
            opp = [SELECT Id, Account.Age__pc, Account.Gender__pc, Account.Salutation, Account.FirstName, Account.LastName, Account.MiddleName, Account.Suffix, 
                InsurancePurpose__c, HealthAssessment__c, TobaccoUse__c, Affiliation__r.Name, ProposedCoverage__c, Account.DomicileState__c FROM Opportunity WHERE Id = : opportunityId LIMIT 1];
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occurred while getting consumer info.', 'ConsumerInfoController.cls', opportunityId, 'getOpportunityFieldsData', 
                            null, 'MarketingHistory', null);
        }
        return opp;
    }
}
