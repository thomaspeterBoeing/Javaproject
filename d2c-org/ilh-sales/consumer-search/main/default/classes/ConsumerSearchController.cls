/***
Copyright: CUNA Mutual Group
Purpose: ConsumerSearch- Search Customers from CPS and Salesforce and dedupes results.
Param: Search Criteria
Created By      Bernie Shishaye   
Created Date:   9/27/2023  
Modified By:    Bernie Shishaye
Modified Date:   9/7/2023
***/
public without sharing class ConsumerSearchController {
    
    
    /***
        Copyright: CUNA Mutual Group
        Purpose: ConsumerSearch- Search Customers from CPS and Salesforce and dedupes results.
        Param: Search Criteria
        Created By      Bernie Shishaye   
        Created Date:   9/27/2023  
        Modified By:    Bernie Shishaye
        Modified Date:   9/7/2023
    ***/
    @AuraEnabled
    public static List<ILHConsumerResultsWrapper> search(Map<String, Object> kvpSearchCriteria) {       
        return (new ILHSearchService()).runSearch(kvpSearchCriteria);    
    }

    /**
     * Author : Bernie Shishaye
     * Date   : 9/12/2023  
     * For Sutherland- when a Seller agent opens an inbound call, the link should do consumer search based on callee phone number.
     * First check if the number is in the excluded list, and do the search.
    */
    @AuraEnabled
    public static Boolean checkPhoneExclusionFlag(string phoneNumber) {         
        string nonDigits = '[^0-9]';
        string strPhone = phoneNumber.replaceAll(nonDigits,'');
        NonSearchableNumber__mdt obj = null;
        List<NonSearchableNumber__mdt> ls = [SELECT Id, DeveloperName,ExcludedNumber__c FROM NonSearchableNumber__mdt WHERE ExcludedNumber__c=:strPhone];
        if (!ls.isEmpty()) {
            obj = ls[0];
        }
        return obj!=null?true:false;
    }
}