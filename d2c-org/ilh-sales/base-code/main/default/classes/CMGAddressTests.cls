@isTest
public with sharing class CMGAddressTests {
	static testMethod void testCMGAddress() {
		CMGAddress.CommonAddressType CAT = new CMGAddress.CommonAddressType();
        CAT.City='Pune';
        CAT.StateProvince='5009205';
        CAT.PostalCode ='44223';
        CAT.Country='USA';
        
        List<String> AddressLines1 =new List<String> ();
        AddressLines1.add('test');
        CAT.AddressLines = AddressLines1;
        
		CMGAddress.AddressStandardizationInfoType ASIT = new CMGAddress.AddressStandardizationInfoType();
        ASIT.AddressStandardizationType='address';
        ASIT.ConfidenceCode='64654';    
        
		CMGAddress.CompleteAddressType CtAT = new CMGAddress.CompleteAddressType();
        List<String> AddressType1 =new List<String>();
        AddressType1.add('test');
        CtAT.AddressType=AddressType1;
        
        List<String> AddressLines2 =new  List<String>();
        AddressLines2.add('testw');
        CtAT.AddressLines=AddressLines2;
        
        CtAT.UspsDeliveryLines= new CMGAddress.UspsDeliveryLinesType();
        CtAT.StreetAddressGroup='Usa Street';
        CtAT.City='pune';
        CtAT.StateProvinceCode='888';
        CtAT.StateProvince='MH';
        CtAT.ZipCode='412114';
        CtAT.Country='India';
        CtAT.PostalCode='412114';
        CtAT.CountryCode='IND'; 
        CtAT.County='India';
        CtAT.Region='Asia';
        CtAT.RegionCode='AS';
        CtAT.Township='Test ts';
        CtAT.StartDate=system.today();
        CtAt.EndDate =system.today(); 
        CtAT.YearsAtAddress =10.2;
        CtAT.RecurringStartMonthDay='SAT';
        CtAT.RecurringEndMonthDay='Mon';
        CtAt.AddressDerivedKey='ADk';
        
        CtAt.AddressStandardizationInfo =new CMGAddress.AddressStandardizationInfoType();
		CMGAddress.LegalAddressType LAT = new CMGAddress.LegalAddressType();
        LAT.LegalAddressCode='8888';
        LAT.Description='duisasa';
        
        List<CMGAddress.LegalAddressType> LATS = new List<CMGAddress.LegalAddressType>();
        LATS.add(LAT);
        CtAt.LegalAddress = LATS;
        
		CMGAddress.StandardizedAddressType SAT = new CMGAddress.StandardizedAddressType();
        List<String> AddressLines3 =new List<String>();
        AddressLines3.add('test');
        SAT.AddressLines=AddressLines3;
        SAT.City ='HYD';
        SAT.StateProvince ='Test';   
        SAT.PostalCode='500950';
        SAT.Country='India';
        SAT.AddressDerivedKey='ind';  
        CMGReusable.GeographicInfoType git = new CMGReusable.GeographicInfoType();
        git.Latitude = '111111111';
        git.Longitute = '111111111';
        SAT.GeographicInfo = git;
        
        SAT.AddressStandardizationInfo= new CMGAddress.AddressStandardizationInfoType();
		CMGAddress.USMailingAddressType UMAT = new CMGAddress.USMailingAddressType();
        List<String> AddressLines5 =new List<String>();
        AddressLines5.add('tset');
        UMAT.AddressLines=AddressLines5;
        UMAT.StreetAddressGroup ='Tes';
        UMAT.City='pune';
        UMAT.StateProvinceCode='5084555';
        UMAT.ZipCode='845745'; 
        
        UMAT.UspsDeliveryLines =new CMGAddress.UspsDeliveryLinesType();
		CMGAddress.UspsDeliveryLinesType UDLT = new CMGAddress.UspsDeliveryLinesType();
        UDLT.OptionalInfo ='opinfo';
		UDLT.SupplementalDeliveryLine='sdl';
        UDLT.PrimaryDeliveryLine ='pdl';
	}
}