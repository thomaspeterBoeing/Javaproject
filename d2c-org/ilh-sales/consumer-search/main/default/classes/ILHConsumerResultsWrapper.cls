/**********************************************************************************
 * Title:  ILHSearch Result Wrapper
 * Date:   Sept 2023
 * 
 * Description:  Responses from CPS and SF will be marshalled to this type.  
 *  
 * Details    :  This is a container class that holds search results. Response from CPS and SF will be marshalled to this type for uniformity.        
 * Modifications:
 *************************************************************************************/

/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-12 12:49:32
 * @Modified by: Daniel Lin
 * @Modified time: 2023-09-12 18:16:58
 * @Description: This is a container class that holds search results. Response from CPS and SF will be marshalled to this type for uniformity.
 */
public class ILHConsumerResultsWrapper {
    public static final String SF_SOURCE_SYSTEM_ID = 'SFORCECS';//Indicates the id for the current Salesforce instance id

    public CMGCommon.ConsumerMarketingGenderType genderObj;
    public List<CMGPerson.PhoneType> phoneList;
    public List<CMGCommon.ConsumerMarketingAddressType> addressList;
    public List<CMGCommon.SourceRecordType> sourceRecordList;
    public enum Source {CPS, SALESFORCE}

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
    public Source mySource;
    @AuraEnabled    
    public List<String> addressLines = new List<String>();
    @AuraEnabled    
    public List<String> sourceSystemKeys = new List<String>();

    public ILHConsumerResultsWrapper(){   
    }

    /**
     * Constructor that parses an Account to Wrapper object
     * @param accnt --Salesforce account record
     */
    public ILHConsumerResultsWrapper(Account accnt) {
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
        mySource = Source.SALESFORCE; 
        sourceSystemKeys = new List<String>{accnt?.PersonContactId};       
    }

    /**
    ***************************************************************************************************************************************
    @Method Name    : applyBusinessRules
    @author         : Adam Perschke-Ely
    @param results  : List of ILHConsumerResultsWrapper results
    @description    : This method applies business rules after results are found.
    ***************************************************************************************************************************************
    */
    public static List<ILHConsumerResultsWrapper> applyBusinessRules(List<ILHConsumerResultsWrapper> results, Source newSource) {
        for(ILHConsumerResultsWrapper result : results) {
            result.mySource = newSource;
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

            //Mapping contactIds
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
}