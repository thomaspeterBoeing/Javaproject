@isTest
public with sharing class CMGPersonTests {
    @isTest
	static void testCMGAddress() {
		CMGPerson.BirthDateInfoType BDIT = new CMGPerson.BirthDateInfoType();
        BDIT.BirthDateType='testbdt';
        BDIT.BirthDate=system.today();
        BDIT.IncompleteBirthDate='test';
        
		CMGPerson.CompleteEmailAddressType CEAT = new CMGPerson.CompleteEmailAddressType();
		CEAT.setEmailType(CMGPerson.CompleteEmailAddressType_EmailType.HOME);
		CEAT.setEmailType(CMGPerson.CompleteEmailAddressType_EmailType.WORK);
		CEAT.setEmailType(CMGPerson.CompleteEmailAddressType_EmailType.PRIMARY);
		CEAT.setEmailType(CMGPerson.CompleteEmailAddressType_EmailType.SECONDARY);
        
        CEAT.EmailAddress= new CMGPerson.EmailAddressType();
        CEAT.EmailStatus= new CMGPerson.EmailStatusType();
		CMGPerson.CompletePersonNameType CPNT = new CMGPerson.CompletePersonNameType();
        CPNT.FullName ='test full name';
        CPNT.PreviousLastName='test plname';
        CPNT.NickName='test nickname';
        CPNT.Initials='HN';    
        
		
            
		CMGPerson.CompletePersonType CPT = new CMGPerson.CompletePersonType();
        CPT.CompletePersonPPIData= new CMGPerson.CompletePersonPPIDataType();
		CMGPerson.CompletePhoneType CPhT = new CMGPerson.CompletePhoneType();
        CPhT.Extension='02415415';
        
        CMGPerson.CompletePersonPPIDataType CPPPIDT = new CMGPerson.CompletePersonPPIDataType();
        CPPPIDT.GenderCode='M';
        CPPPIDT.BirthDateInfo =new CMGPerson.BirthDateInfoType();
        CPPPIDT.MaritalStatusCode='UM';
        CPPPIDT.MaritalStatusDate=system.today();
        CPPPIDT.TaxId ='5465465';
        CPPPIDT.TaxIdLastFour='64564';
        CPPPIDT.NonTaxIdentity='65654';
        CPPPIDT.NonTaxIdentityCode='65614';
        CPPPIDT.HomeAddress = new CMGAddress.CompleteAddressType();
        List<CMGPerson.CompletePhoneType> cpts = new List<CMGPerson.CompletePhoneType>();
        cpts.add(CPhT);
        CPPPIDT.CompletePhone = cpts;
        
		CMGPerson.EmailStatusType EST = new CMGPerson.EmailStatusType();
        EST.Status='test';
        EST.StatusDateTime=system.today();
        
		CMGPerson.PersonNameType PNT = new CMGPerson.PersonNameType();
        PNT.Prefix='Mr';
        PNT.FirstName='estFn'; 
        PNT.MiddleName='tets mn';
        PNT.LastName='test ln';
        PNT.Suffix ='testsf';
        PNT.Designation ='SE';
        
        CMGAddress.CompleteAddressType CtAT = new CMGAddress.CompleteAddressType();
        List<String> AddressType1 =new List<String>();
        AddressType1.add('test');
        CtAT.AddressType=AddressType1;
        
        List<CMGAddress.CompleteAddressType> ctats = new List<CMGAddress.CompleteAddressType>();
        ctats.add(CtAT);
        
		CMGPerson.PersonType PT = new CMGPerson.PersonType();
        PT.PersonId='4565';
        PT.DeathDate=system.today();
        PT.DeceasedIndicator=true;
        PT.PreferredMethodOfCorrespondence='testppmc';
        PT.OtherAddresses = ctats;
        
        List<CMGPerson.CompleteEmailAddressType> ceats = new List<CMGPerson.CompleteEmailAddressType>();
        ceats.add(CEAT);
        PT.CompleteEmailAddress = ceats;
        
		CMGPerson.PhoneType PhT = new CMGPerson.PhoneType();
        PhT.PhoneNumber='9854588526';
		system.debug(PhT.getPhoneType());
		PhT.setPhoneType(CMGPerson.PhoneType_PhoneType.HOME);
		system.debug(PhT.getPhoneType());
		PhT.setPhoneType(CMGPerson.PhoneType_PhoneType.WORK);
		system.debug(PhT.getPhoneType());
		PhT.setPhoneType(CMGPerson.PhoneType_PhoneType.MOBILE);
		system.debug(PhT.getPhoneType());
		PhT.setPhoneType(CMGPerson.PhoneType_PhoneType.FAX);
		system.debug(PhT.getPhoneType());
        
		CMGPerson.SimplePersonType SPT = new CMGPerson.SimplePersonType();
        SPT.GenderCode='MAle';
        SPT.BirthDate=system.today();
        SPT.HomeAddress =new CMGAddress.CommonAddressType();
        SPT.Phone =new CMGPerson.PhoneType();
        SPT.EmailAddress='test@mail.com';
        SPT.TaxId='5654';
        SPT.AccountNumber='464646';
        
        CMGPerson.EmailAddressType EAT = new CMGPerson.EmailAddressType();
        EAT.value='test';
        
        CMGPerson.EmailAddressType EAT2 = new CMGPerson.EmailAddressType('test@gmail.com');
	}
}