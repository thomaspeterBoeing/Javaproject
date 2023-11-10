/***
Copyright: TruStage
Purpose: This class wraps marketing history results
1.0 - Adam Perschke-Ely   - 11/2/2023  - Created for new D2C Salesfore instance.
***/
public with sharing class ILHMarketingHistoryResultsWrapper {
    @AuraEnabled
    public String sourceId;
    @AuraEnabled
    public Date mailingDate;
    @AuraEnabled
    public String offerDescription;
    @AuraEnabled
    public String campaignProduct;
    @AuraEnabled
    public String channelCode;
    @AuraEnabled
    public String creditUnion;
    @AuraEnabled
    public String contractNumber;
    
    public ILHMarketingHistoryResultsWrapper(){}

    /**
    * Purpose: This method filters out results that don't meet business criteria
    * @return -- List of filtered results
    */
    public static List<ILHMarketingHistoryResultsWrapper> filterResults(List<ILHMarketingHistoryResultsWrapper> results) {
        if(results != null && results.size() > 0) {
            List<ILHMarketingHistoryResultsWrapper> filteredResults = new List<ILHMarketingHistoryResultsWrapper>();
            for(ILHMarketingHistoryResultsWrapper result : results) {
                if(result.mailingDate != null) {
                    if(result.mailingDate.daysBetween(Date.today()) <= 365 || result.mailingDate > Date.today()) {//Mailing date is within the past year or future
                        filteredResults.add(result);
                    }
                }
            }
            results = filteredResults;
        }
        return results;
    }

    /**
    * Purpose: Finds credit union from Salesforce based on Contract Number
    * @return -- Results with credit union names populated
    */
    public static List<ILHMarketingHistoryResultsWrapper> findCreditUnions(List<ILHMarketingHistoryResultsWrapper> results) {
        Set<String> lstContractNumbers = new Set<String>();
        Map<String, String> mapContractToName = new Map<String, String>();
        if(results != null) {
            for(ILHMarketingHistoryResultsWrapper sr : results) {
                lstContractNumbers.add(sr.contractNumber);
            }
        }

        //Find related Account records from Salesforce
        for(Account a : [SELECT Name, ContractNumberUnformatted__c FROM Account WHERE ContractNumberUnformatted__c in :lstContractNumbers]) {
            mapContractToName.put(a.ContractNumberUnformatted__c, a.name);
        }

        //Assigning a credit union name value to the credit union field
        for(ILHMarketingHistoryResultsWrapper sr : results) {
            sr.creditUnion = mapContractToName.get(sr.contractNumber);
        }
        return results;
    }
}