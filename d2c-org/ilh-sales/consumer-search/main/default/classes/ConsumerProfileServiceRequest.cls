/**
 * Copyright: TruStage
 * Purpose: Request object to interact with the Consumer Profile web service.
 */
public class ConsumerProfileServiceRequest {
    
    public SearchConsumerProfileType SearchConsumerProfile  { get; set; }
    public SearchRequestInfoType SearchRequestInfo          { get; set; }
    
    /**
     * Purpose: Contructor for Consumer Search Profile and Search Request Info
     * @param searchConsumerProfile : consumer search profile
     * @param searchRequestInfo : search request info
     */
    public ConsumerProfileServiceRequest(SearchConsumerProfileType searchConsumerProfile, SearchRequestInfoType searchRequestInfo) {
        this.SearchConsumerProfile = searchConsumerProfile;
        this.SearchRequestInfo = searchRequestInfo;
    }
    
    //Types of elements from CPS service
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
    
    /**
     * Purpose: This inner class represents the consumer search profile type
     */
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
        
        /**
         * Purpose: Fully constructs a usable SearchConsumerProfileType using just a SearchCriteria parameter
         * @param searchCriteria : criteria to search on
         */
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
     * Purpose: Inner class to encapsulate Search Criteria for CPS calls, basically a simplified version of the SearchConsumerProfileType that CPSServiceRequest needs.
     * This is better encapsulated than a bunch of individual fields/parameters, has a more specific purpose than our “does way too much” MemberSearchResultsWrapper, 
     * and is easier to use than a raw SearchConsumerProfileType
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
    
    /**
     * Purpose: Inner class that indicates the type of elements to return
     */
    public class SearchRequestInfoType {
        public List<Integer> ElementsToReturn               { get; set; }
        public Integer MaxResultsToReturn                   { get; set; }
        
        /**
         * Purpose: This method return the elements to return based on index value
         * @param vals : Elements that you want to return
         */
        public void setElementsToReturn(SearchRequestInfoType_enumElementsToReturn[] vals) {
            ElementsToReturn = new List<Integer>();
            for (SearchRequestInfoType_enumElementsToReturn val: vals) {
                ElementsToReturn.add(val.ordinal());               
            }
        } 
    }
}