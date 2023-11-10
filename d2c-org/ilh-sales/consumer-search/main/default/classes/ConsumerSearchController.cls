/**
 * Copyright: TruStage
 * Purpose: Request object to interact with the Consumer Profile web service.
 */
public class ConsumerSearchController {
    /**
     * Purpose: ConsumerSearch- Search Customers from CPS and Salesforce and dedupes results.
     * @param kvpSearchCriteria : Criteria to search on
     * @return : An instance of the ILHConsumerResultsWrapper class with results.
    */
    @AuraEnabled
    public static ILHConsumerResultsWrapper search(Map<String, Object> kvpSearchCriteria) {       
        return (new ILHSearchService()).runSearch(kvpSearchCriteria);//We only return one instance of the wrapper the contains merged errors and results from various search services.    
    }

    /**
     * Purpose: For Sutherland- when a Seller agent opens an inbound call, the link should do consumer search based on callee phone number.
     * First check if the number is in the excluded list, and do the search.
     * @param phoneNumber : Phone number to dertermine if it's a searchable number.
     * @return : Boolean value that indicates if a phone number is searchable
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