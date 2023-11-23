/**
 * Copyright: TruStage
 * Purpose: This is a container class that holds search results. Response from CPS and SF will be marshalled to this type for uniformity.
 */
public class ILHConsumerResultsWrapper {
    public static final String SF_SOURCE_SYSTEM_ID = 'SFILHSALES';//Indicates the id for the current Salesforce instance id
    public enum Source {CPS, SALESFORCE}
    public Source mySource;

    @AuraEnabled
    public List<SearchResult> results = new List<SearchResult>();
    @AuraEnabled
    public List<String> errors = new List<String>();

    public ILHConsumerResultsWrapper(){   
    }

    /**
     * Purpose: This method applies business rules after results are found.
     */
    public List<SearchResult> applyBusinessRules() {
        for(SearchResult result : results) {
            //Mapping phone numbers
            if (result?.phoneList != null) {
                for (CMGPerson.PhoneType phone : result.phoneList) {
                    if (phone != null && phone?.getPhoneType() == CMGPerson.PhoneType_PhoneType.HOME) {
                        result.homePhone = phone?.PhoneNumber;
                    } else if (phone != null && phone.getPhoneType() == CMGPerson.PhoneType_PhoneType.WORK) {
                        result.workPhone = phone?.PhoneNumber;
                    }
                    else if (phone != null && phone.getPhoneType() == CMGPerson.PhoneType_PhoneType.MOBILE) {
                        result.mobilePhone = phone?.PhoneNumber;
                    }
                }
            }

            //Mapping gender values
            CMGCommon.ConsumerMarketingGenderType_GenderCode genderCode = result?.genderObj?.getGenderCode();
            if (genderCode == CMGCommon.ConsumerMarketingGenderType_GenderCode.MALE) {
                result.gender = 'Male';
            } else if (genderCode == CMGCommon.ConsumerMarketingGenderType_GenderCode.FEMALE) {
                result.gender = 'Female';
            } else {
                // Leave null, there are other Gender Codes but we just display blank
            }

            //Mapping address fields
            if (result?.addressList != null) {
                for(CMGCommon.ConsumerMarketingAddressType address : result.addressList) {
                    if (address?.PreferredFlag != null && address.PreferredFlag) {//Is preferred address, then map address fields
                        result.city = address?.City;
                        result.stateProvince = address?.StateProvince;
                        result.postalCode = address?.PostalCode;
                        result.addressLines = address?.AddressLines;
                    }
                }
            }

            //Mapping accountIds
            if (result?.sourceRecordList != null) {
                for (CMGCommon.SourceRecordType source : result.sourceRecordList) {
                    //Source system id is equal to current Salesforce instance id
                    if (source?.SourceSystemId != null && source?.SourceSystemKey != null && source.SourceSystemId.equalsIgnoreCase(SF_SOURCE_SYSTEM_ID)) {
                        if (result?.sourceSystemKeys == null) {
                            result.sourceSystemKeys = new List<String>();
                        }                        
                        result.sourceSystemKeys.add(source.SourceSystemKey);//Add person contact id to list of source system keys
                    }
                }
            }
        }
        return results;
    }

    /**
     * Purpose: This inner class contains search results from various search services
     */
    public class SearchResult {
        public CMGCommon.ConsumerMarketingGenderType genderObj;
        public List<CMGPerson.PhoneType> phoneList;
        public List<CMGCommon.ConsumerMarketingAddressType> addressList;
        public List<CMGCommon.SourceRecordType> sourceRecordList;
        public ILHConsumerResultsWrapper.Source mySource;

        @AuraEnabled    
        public String firstName;
        @AuraEnabled    
        public String lastName;
        @AuraEnabled    
        public String middleName;
        @AuraEnabled    
        public String nameSuffix;
        @AuraEnabled    
        public String personId;
        @AuraEnabled    
        public Date dateOfBirth;
        @AuraEnabled    
        public String gender;
        @AuraEnabled    
        public String SSNLast4;
        @AuraEnabled    
        public String homePhone;
        @AuraEnabled    
        public String workPhone;
        @AuraEnabled    
        public String mobilePhone;
        @AuraEnabled    
        public String city;
        @AuraEnabled    
        public String postalCode;
        @AuraEnabled    
        public String stateProvince;
        @AuraEnabled    
        public List<String> addressLines = new List<String>();
        @AuraEnabled    
        public List<String> sourceSystemKeys = new List<String>();

        /**
         * Purpose: Default constructor for Search Result
         */
        public SearchResult() {}

        /**
         * Purpose: Constructor that parses an Account to Search Result object
         * @param accnt --Salesforce account record
         */
        public SearchResult(Account accnt) {
            firstName = accnt?.FirstName;
            lastName = accnt?.LastName;
            nameSuffix = accnt?.Suffix;
            city = accnt?.PersonMailingCity;
            //If address has multiple lines then we'll split it into muliple elements and add to list of strings.
            //Example consumer lives in appartment.  123 Main St., Apt #123
            addressLines = accnt?.PersonMailingStreet != null ? new List<String>(accnt?.PersonMailingStreet?.split(',')) : null;
            stateProvince = accnt?.PersonMailingState;
            postalCode = accnt?.PersonMailingPostalCode;
            SSNLast4 = accnt?.SSNLast4__pc;
            gender = accnt?.Gender__pc;
            homePhone = accnt?.PersonHomePhone;
            workPhone = accnt?.PersonOtherPhone;
            mobilePhone = accnt?.PersonMobilePhone;
            personId = accnt?.PersonID__pc;
            dateOfBirth = accnt?.PersonBirthdate;
            sourceSystemKeys = new List<String>{accnt?.Id};       
        }
    }
}