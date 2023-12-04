/**
 * Copyright: TruStage
 * Purpose: Request object to interact with the Consumer Profile update web service.
 */
public class ConsumerProfileUpdateRequest {
    public CMGCommon.SourceRecordType SourceRecord { get; set; }
    public CMGCommon.ConsumerMarketingPersonType ConsumerMarketingPerson { get; set; }
    public List<CMGCommon.MembershipType> MembershipList { get; set; }

    /**
     * Purpose: This constructor transform a Account record into a request object
     * @param acc -- Account record to transform to a request object
     */
    public ConsumerProfileUpdateRequest(Account acc) {
        SourceRecord = new CMGCommon.SourceRecordType();
        ConsumerMarketingPerson = new CMGCommon.ConsumerMarketingPersonType();
        MembershipList = new List<CMGCommon.MembershipType>();

        //Creating SourceRecord request
        SourceRecord.SourceSystemKey = acc.Id;
        SourceRecord.SourceSystemId =  'SFILHSALES';
        
        //Setting person id
        if (String.isNotEmpty(acc?.PersonID__pc)) {
            ConsumerMarketingPerson.PersonId = acc.PersonID__pc;
        }
        
        //Setting org information
        if (String.isNotEmpty(acc?.ContractNumberUnformatted__c)) {
            CMGCommon.MembershipType membershipType = new CMGCommon.MembershipType();
            CMGReusable.OrganizationType organization = new CMGReusable.OrganizationType();
            organization.ContractNumber = acc.ContractNumberUnformatted__c;
            membershipType.Organization = organization;
            MembershipList.add(membershipType);
        }

        //Setting name fields
        CMGCommon.ConsumerMarketingPersonNameType marketingPersonName = new CMGCommon.ConsumerMarketingPersonNameType();
        if (String.isNotEmpty(acc?.FirstName)) {
            marketingPersonName.FirstName = acc.FirstName;
        }
            
        if (String.isNotEmpty(acc?.LastName)) {
            marketingPersonName.LastName = acc.LastName;
        }
            
        if (String.isNotEmpty(acc?.Suffix)) {
            marketingPersonName.Suffix = acc.Suffix;
        }
            
        if (String.isNotEmpty(acc?.MiddleName)) {
            marketingPersonName.MiddleName = acc.MiddleName;
        }
            
        if (String.isNotEmpty(marketingPersonName?.FirstName) || String.isNotEmpty(marketingPersonName?.LastName) || String.isNotEmpty(marketingPersonName?.Suffix) || String.isNotEmpty(marketingPersonName?.MiddleName)) {
            marketingPersonName.EffectiveChangedAttribute = newEffectiveChangedAttribute();
            ConsumerMarketingPerson.ConsumerMarketingPersonName = marketingPersonName;
        }

        //Setting birthdate field
        if (acc?.PersonBirthdate != null) {
            CMGCommon.ConsumerMarketingBirthDateType birthDateType = new CMGCommon.ConsumerMarketingBirthDateType();
            birthDateType.ChangedAttribute = newChangedAttribute();
            birthDateType.BirthDate = acc.PersonBirthdate;
            ConsumerMarketingPerson.BirthDateInformation = birthDateType;
        }

        //Setting gender field
        if (String.isNotEmpty(acc?.Gender__pc)) {
            CMGCommon.ConsumerMarketingGenderType genderType = new CMGCommon.ConsumerMarketingGenderType();
            if (acc.Gender__pc == 'Male') {
                genderType.setGenderCode(CMGCommon.ConsumerMarketingGenderType_GenderCode.MALE);
            } else if (acc.Gender__pc == 'Female') {
                genderType.setGenderCode(CMGCommon.ConsumerMarketingGenderType_GenderCode.FEMALE);
            }
            genderType.ChangedAttribute = newChangedAttribute();
            ConsumerMarketingPerson.Gender = genderType;
        }

        //Setting phone fields
        List<CMGCommon.ConsumerMarketingPhoneType> phones = new List<CMGCommon.ConsumerMarketingPhoneType>();
        CMGCommon.ConsumerMarketingPhoneType homePhone = new CMGCommon.ConsumerMarketingPhoneType();
        CMGCommon.ConsumerMarketingPhoneType workPhone = new CMGCommon.ConsumerMarketingPhoneType();

        if (acc?.PersonHomePhone != null) {
            homePhone.PhoneNumber = acc.PersonHomePhone;
            homePhone.setPhoneType(CMGPerson.PhoneType_PhoneType.HOME);
            homePhone.EffectiveChangedAttribute = newEffectiveChangedAttribute();
            phones.add(homePhone);
        }

        if (acc?.PersonOtherPhone != null) {
            workPhone.PhoneNumber = acc.PersonOtherPhone;
            workPhone.setPhoneType(CMGPerson.PhoneType_PhoneType.WORK);
            workPhone.EffectiveChangedAttribute = newEffectiveChangedAttribute();
            phones.add(workPhone);
        }

        if (String.isNotEmpty(homePhone?.PhoneNumber) || String.isNotEmpty(workPhone?.PhoneNumber)) {
            ConsumerMarketingPerson.PhoneList = phones;
        }

        //Setting address fields
        CMGCommon.ConsumerMarketingAddressType primaryAddress = new CMGCommon.ConsumerMarketingAddressType();

        if (String.isNotEmpty(acc?.PersonMailingCity)) {
            primaryAddress.City = acc.PersonMailingCity;
        }

        if (String.isNotEmpty(acc?.PersonMailingStreet)) {
            primaryAddress.AddressLines = acc.PersonMailingStreet.split(',');
        }

        if (String.isNotEmpty(acc?.PersonMailingState)) {
            primaryAddress.StateProvince = acc.PersonMailingState;
        }

        if (String.isNotEmpty(acc?.PersonMailingPostalCode)) {
            primaryAddress.PostalCode = acc.PersonMailingPostalCode;
        }

        if (String.isNotEmpty(primaryAddress?.City) || (primaryAddress?.AddressLines != null && !primaryAddress?.AddressLines?.isEmpty()) || String.isNotEmpty(primaryAddress?.StateProvince) || String.isNotEmpty(primaryAddress?.PostalCode)) {
            List<CMGCommon.ConsumerMarketingAddressType> addressList = new List<CMGCommon.ConsumerMarketingAddressType>();
            primaryAddress.EffectiveChangedAttribute = newEffectiveChangedAttribute();
            addressList.add(primaryAddress);
            ConsumerMarketingPerson.AddressList = addressList;
        }
    }

    private CMGReusable.EffectiveChangedAttributeType newEffectiveChangedAttribute() {
        CMGReusable.EffectiveChangedAttributeType effectiveChangedAttribute = new CMGReusable.EffectiveChangedAttributeType();
        CMGReusable.ValidationInfoType validationInfo = new CMGReusable.ValidationInfoType();
        validationInfo.ValidationDateTime = DateTime.Now();
        effectiveChangedAttribute.ValidationInfo = validationInfo;
        return effectiveChangedAttribute;
    }

    private CMGReusable.ChangedAttributeType newChangedAttribute() {
        CMGReusable.ValidationInfoType validationInfo = new CMGReusable.ValidationInfoType();
        CMGReusable.ChangedAttributeType changedAttribute = new CMGReusable.ChangedAttributeType();
        validationInfo.ValidationDateTime = DateTime.Now();
        changedAttribute.ValidationInfo = validationInfo;
        return changedAttribute;
    }
}