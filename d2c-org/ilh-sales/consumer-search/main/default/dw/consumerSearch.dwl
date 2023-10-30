%dw 2.0
input payload application/json
output application/apex
---
payload.ConsumerProfileList map(x)-> {
    personId: x.ConsumerMarketingPerson.PersonId default '',
    firstName: x.ConsumerMarketingPerson.ConsumerMarketingPersonName.FirstName default '',    
    lastName: x.ConsumerMarketingPerson.ConsumerMarketingPersonName.LastName default '',   
    middleName: x.ConsumerMarketingPerson.ConsumerMarketingPersonName.MiddleName default '',
    nameSuffix: x.ConsumerMarketingPerson.ConsumerMarketingPersonName.Suffix default '',
    dateOfBirth : x.ConsumerMarketingPerson.BirthDateInformation.BirthDate as Date default null,
    SSNLast4: x.ConsumerMarketingPerson.SocialSecurityNumberInformation.TaxIdLastFour default '',
    genderObj: ({
        GenderCode: x.ConsumerMarketingPerson.Gender.GenderCode default null
    } as Object {class: "CMGCommon.ConsumerMarketingGenderType"}),
    phoneList: (x.ConsumerMarketingPerson.PhoneList map ((item) -> {
        PhoneType: item.PhoneType default null,
        PhoneNumber: item.PhoneNumber default ''
    } as Object {class: "CMGPerson.PhoneType"})),
    addressList: (x.ConsumerMarketingPerson.AddressList map ((item) -> {
        StateProvince: item.StateProvince default '',
        City: item.City default '',
        PostalCode: item.PostalCode default '',
        AddressLines: item.AddressLines default null,
        PreferredFlag: item.PreferredFlag default null
    } as Object {class: "CMGCommon.ConsumerMarketingAddressType"})),
    sourceRecordList: (x.SourceRecordList map ((item) -> {
        SourceSystemId: item.SourceSystemId default '',
        SourceSystemKey: item.SourceSystemKey default ''
    } as Object {class: "CMGCommon.SourceRecordType"}))
} as Object {class: "ILHConsumerResultsWrapper"}