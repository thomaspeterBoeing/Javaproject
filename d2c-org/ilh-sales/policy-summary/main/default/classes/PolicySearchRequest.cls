/**********************************************************************************
 * Title:  PolicySearchRequest
 * Date:   Oct 2023
 * 
 * Description:  Request object to interact with the Consumer Profile web service.  
 *   
 * Modifications:
 *************************************************************************************/

public with sharing class PolicySearchRequest {
    public SearchConsumerProfileType SearchConsumerProfile  { get; set; }
    public SearchRequestInfoType SearchRequestInfo          { get; set; }
    
    public PolicySearchRequest(SearchConsumerProfileType searchConsumerProfile, SearchRequestInfoType searchRequestInfo) {
        this.SearchConsumerProfile = searchConsumerProfile;
        this.SearchRequestInfo = searchRequestInfo;
    }
    
    public enum SearchRequestInfoType_enumElementsToReturn {
        PERSONID,
        NAME,
        DEATHDATE,
        DECEASEDINDICATOR,
        EMAIL,
        GENDER,
        BIRTHDATE,
        MARITALSTATUS,
        ADDRESS,
        PHONE,
        TAXID,
        TAXIDLASTFOUR,
        MEMBERSHIP,
        FINANCIALACCOUNT,
        PRODUCTSUMMARY,
        APPLICATION,
        SUPPRESSION,
        MARKETINGOPTOUT,
        SOURCERECORD,
        EMAILCONTACTHISTORY,
        DIRECTMAILCAMPAIGNCONTACTHISTORY,
        PHONECONTACTHISTORY,
        DIRECTMAILCONTACTHISTORY
        
    }
    
    public class SearchConsumerProfileType {
        public String PersonId                              { get; set; }
        
        // Fully constructs a usable SearchConsumerProfileType using just a SearchCriteria parameter
        public SearchConsumerProfileType(SearchCriteria searchCriteria) {
                      
            if(searchCriteria != null) {
                this.PersonId = searchCriteria.personId;
            
            }
        }
    }
        
    public class SearchCriteria {
        
        @AuraEnabled
        public String personId              { get; set; }
    }
    
    
    public class SearchRequestInfoType {
        public List<Integer> ElementsToReturn               { get; set; }
        public Integer MaxResultsToReturn                   { get; set; }
        
        public void setElementsToReturn(SearchRequestInfoType_enumElementsToReturn[] vals) {
            ElementsToReturn = new List<Integer>();
            for (SearchRequestInfoType_enumElementsToReturn val: vals) {
                ElementsToReturn.add(val.ordinal());               
            }
        } 
    }
}