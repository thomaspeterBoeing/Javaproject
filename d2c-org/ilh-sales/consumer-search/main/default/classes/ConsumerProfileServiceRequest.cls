/**********************************************************************************
 * Title:  ConsumerProfileServiceRequest
 * Date:   Sept 2023
 * 
 * Description:  Request object to interact with the Consumer Profile web service.  
 *   
 * Modifications:
 *************************************************************************************/

/***
Copyright: CUNA Mutual Group
Purpose: Request object to interact with the Consumer Profile web service.
1.0 - Louis W (CS) - 5/15/2013 - Created
1.1 - Dave Y       - 7/19/2013 - Modified for internal enum design
***/
public class ConsumerProfileServiceRequest {
    
    public SearchConsumerProfileType SearchConsumerProfile  { get; set; }
    public SearchRequestInfoType SearchRequestInfo          { get; set; }
    
    public ConsumerProfileServiceRequest(SearchConsumerProfileType searchConsumerProfile, SearchRequestInfoType searchRequestInfo) {
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
        public CMGPerson.PersonNameType PersonName          { get; set; }
        public String TaxId                                 { get; set; }
        public String TaxIdLastFour                         { get; set; }
        public Date BirthDate                               { get; set; }
        public CMGAddress.CommonAddressType CommonAddress   { get; set; }
        public String PhoneNumber                           { get; set; }
        public CMGProductSummary.SimpleProductSummaryType SimpleProductSummary { get; set; }
        public Integer ApplicationConfirmationNumber        { get; set; }
        public Integer ContactInteractionId                 { get; set; }
        
        // Fully constructs a usable SearchConsumerProfileType using just a SearchCriteria parameter
        public SearchConsumerProfileType(SearchCriteria searchCriteria) {
            this.ApplicationConfirmationNumber = 0;
            this.ContactInteractionId = 0;
            
            if (searchCriteria != null) {
                this.PersonId = searchCriteria.personId;
                
                if (searchCriteria.ssn != null) {
                    if(searchCriteria.ssn.length() == 9) {
                        this.TaxId = searchCriteria.ssn;
                    } else if(searchCriteria.ssn.length() >= 4) {
                        this.TaxIdLastFour = searchCriteria.ssn.remove('*');
                    }
                }   
                    
                if (searchCriteria.phoneNumber != null) {
                    this.PhoneNumber = searchCriteria.phoneNumber.replace('-','').replace('(','').replace(')','').replace(' ','');
                }
                
                if ((searchCriteria.city != null) || (searchCriteria.zipCode != null) || (searchCriteria.state != null)) {
                    this.CommonAddress = new CMGAddress.CommonAddressType();
                    
                    this.CommonAddress.City = searchCriteria.city;
                    this.CommonAddress.PostalCode = searchCriteria.zipCode;
                    this.CommonAddress.StateProvince = searchCriteria.state;
                }
                
                if ((searchCriteria.firstName != null) || (searchCriteria.lastName != null)) {
                    this.PersonName = new CMGPerson.PersonNameType();                    
                    
                    this.PersonName.LastName = searchCriteria.lastName;
                    this.PersonName.FirstName = searchCriteria.firstName;
                }
                
                if (searchCriteria.dateOfBirth != null) {
                    String BirthDateStr = Utilities.DateFormatSwitchMMDDYYYTtoYYYYMMDD(searchCriteria.dateOfBirth);
                    if (BirthDateStr != null) {
                        this.BirthDate = Date.valueOf(BirthDateStr);
                    }
                }
                
                if ((searchCriteria.policyNumber != null) && (searchCriteria.policyNumber != '')) {
                    this.SimpleProductSummary = new CMGProductSummary.SimpleProductSummaryType();
                    this.SimpleProductSummary.ProductNumber = searchCriteria.policyNumber;
                }
            }
        }
    }
    
    /**
        Inner class to encapsulate Search Criteria for CPS calls, basically a simplified version of the SearchConsumerProfileType that CPSServiceRequest needs.
        This is better encapsulated than a bunch of individual fields/parameters, has a more specific purpose than our “does way too much” MemberSearchResultsWrapper, 
        and is easier to use than a raw SearchConsumerProfileType
    */
    public class SearchCriteria {
        @AuraEnabled
        public String ssn                   { get; set; }
        @AuraEnabled
        public String phoneNumber           { get; set; }
        @AuraEnabled
        public String firstName             { get; set; }
        @AuraEnabled
        public String lastName              { get; set; }
        @AuraEnabled
        public String city                  { get; set; }
        @AuraEnabled
        public String state                 { get; set; }
        @AuraEnabled
        public String zipCode               { get; set; }
        @AuraEnabled
        public String dateOfBirth           { get; set; }
        @AuraEnabled
        public String policyNumber          { get; set; }
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