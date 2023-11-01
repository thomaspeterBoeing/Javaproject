/***
Copyright: CUNA Mutual Group
Purpose: Unit Tests for methods in the search results wrapper.
Created By      Bernie Shishaye   
Created Date:   8/27/2023  
Modified By:    Bernie Shishaye
Modified Date:   9/7/2023
***/
@isTest
public with sharing class ILHConsumerResultsWrapperTest {
	
	public class WrapperObj{}

	/** SF ConstructorTest */
	@isTest
   	public static void constructorForSF(){         
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account();
        a.FirstName = 'fName';
        a.LastName = 'lName';
        a.RecordTypeId= personRecordTypeId;
        a.Phone = '704-777-8888';
        insert a;
        Account aa = [Select Id, Name, Firstname, LastName,PersonContactId,Suffix,PersonHomePhone,PersonOtherPhone,PersonMobilePhone,PersonMailingStreet,PersonMailingPostalCode, PersonMailingCity,PersonMailingState,SSNLast4__pc,Gender__pc,PersonID__pc, PersonBirthdate FROM Account WHere Id=:a.Id limit 1]; 
         
        ILHConsumerResultsWrapper ilhResult = new ILHConsumerResultsWrapper(aa);       
        Assert.isNotNull(ilhResult, 'is not null');
        Assert.areEqual(aa.FirstName, ilhResult.firstName);
        Assert.areEqual(aa.LastName, ilhResult.lastName);
	}

	@isTest
	public static void applyBusinessRulesTest() {
		CMGCommon.ConsumerMarketingGenderType male = new CMGCommon.ConsumerMarketingGenderType();
		male.GenderCode = 0;

		CMGCommon.ConsumerMarketingGenderType female = new CMGCommon.ConsumerMarketingGenderType();
		female.GenderCode = 1;

		CMGPerson.PhoneType homePhone = new CMGPerson.PhoneType();
		homePhone.PhoneNumber = '111111111';
		homePhone.PhoneType = 1;

		CMGPerson.PhoneType workPhone = new CMGPerson.PhoneType();
		workPhone.PhoneNumber = '222222222';
		workPhone.PhoneType = 2;

		CMGPerson.PhoneType mobilePhone = new CMGPerson.PhoneType();
		mobilePhone.PhoneNumber = '3333333333';
		mobilePhone.PhoneType = 3;

		List<CMGPerson.PhoneType> phones = new List<CMGPerson.PhoneType>{homePhone, workPhone, mobilePhone};

		CMGCommon.ConsumerMarketingAddressType address = new CMGCommon.ConsumerMarketingAddressType();
		address.PreferredFlag = false;
		address.City = 'New York';
		address.StateProvince = 'NY';
		address.PostalCode = '45678';
		address.AddressLines = new List<String>{'456 Main Street'};

		CMGCommon.ConsumerMarketingAddressType address2 = new CMGCommon.ConsumerMarketingAddressType();
		address.PreferredFlag = true;
		address.City = 'Madison';
		address.StateProvince = 'WI';
		address.PostalCode = '12345';
		address.AddressLines = new List<String>{'123 Main Street'};

		List<CMGCommon.ConsumerMarketingAddressType> addresses = new List<CMGCommon.ConsumerMarketingAddressType>{address, address2};

		CMGCommon.SourceRecordType nonSF = new CMGCommon.SourceRecordType();
		nonSF.SourceSystemId = 'ABC';
		nonSF.SourceSystemKey = '1234';

		CMGCommon.SourceRecordType sf = new CMGCommon.SourceRecordType();
		sf.SourceSystemId = ILHConsumerResultsWrapper.SF_SOURCE_SYSTEM_ID;
		sf.SourceSystemKey = '12345';

		List<CMGCommon.SourceRecordType> recordTypes = new List<CMGCommon.SourceRecordType>{nonSF, sf};

		ILHConsumerResultsWrapper result1 = new ILHConsumerResultsWrapper();
		result1.genderObj = male;
		result1.addressList = addresses;
		result1.phoneList = phones;
		result1.sourceRecordList = recordTypes;

		ILHConsumerResultsWrapper result2 = new ILHConsumerResultsWrapper();
		result2.genderObj = female;

		List<ILHConsumerResultsWrapper> results = new List<ILHConsumerResultsWrapper>{result1, result2};

		results = ILHConsumerResultsWrapper.applyBusinessRules(results, ILHConsumerResultsWrapper.Source.CPS);

		Assert.areEqual('Male', results[0].gender);
		Assert.areEqual('111111111', results[0].homePhone);
		Assert.areEqual('222222222', results[0].workPhone);
		Assert.areEqual('3333333333', results[0].mobilePhone);
		Assert.areEqual('Madison', results[0].city);
		Assert.areEqual('WI', results[0].stateProvince);
		Assert.areEqual('12345', results[0].postalCode);
		Assert.areEqual('123 Main Street', results[0].addressLines[0]);
		Assert.areEqual(1, results[0].sourceSystemKeys.size());
		Assert.areEqual('12345', results[0].sourceSystemKeys[0]);

		Assert.areEqual('Female', results[1].gender);
	}
}