@isTest
public class CMGADnDBasicTests {
	@isTest
    public static void getSignedDateTimeStr(){
        Assert.areEqual('1980-01-01', CMGADnDBasic.getDateString(Date.parse('1/1/1980')));
    }
    
    @isTest
    public static void ApplicationInformation(){
        CMGADnDBasic.ApplicationInformation appinfo = new CMGADnDBasic.ApplicationInformation();
        
        appinfo.setProductIdentifierStr('ADD2001');
        appinfo.ContractNumber = '11111';
        appinfo.BasicAmount = '11111111';
        appinfo.EmailAddress = 'test@gmail.com';
        appinfo.MarketingSequenceNumber = '11111';
        appinfo.AgentID = '11111';
        Assert.areEqual('0', appinfo.getProductIdentifierStr());
        
        appinfo.setProductIdentifierEnum(CMGADnDBasic.ADnDEnum_ProductIdentifier.ADD2012);
        system.debug(appinfo.getProductIdentifierEnum());
        
        appinfo.setSignedDateTimeStr('10/14/2011, 12:00 AM');
        Assert.areEqual(DateTime.newInstance(2011,10,14).format('MM/dd/yyyy hh:mm a'), appinfo.getSignedDateTimeStr());
    }

    @isTest
    public static void InsuredInformation(){
        CMGADnDBasic.InsuredInformation insinfo = new CMGADnDBasic.InsuredInformation();
        
        insinfo.setBirthDateStr('1/1/1980');
        insinfo.FirstName = 'TestFirst';
        insinfo.MiddleName = 'TestMiddle';
        insinfo.LastName = 'TestLast';
        insinfo.AddressLine1 = 'Address1';
        insinfo.AddressLine2 = 'Address2';
        insinfo.AddressLine3 = 'Address3';
        insinfo.City = 'Madison';
        insinfo.StateProvinceCode = 'WI';
        insinfo.Zipcode = '11111';
        insinfo.PhoneNumber = '(111) 111-1111';
        Assert.areEqual(DateTime.newInstance(1980,1,1).format('yyyy-MM-dd'), insinfo.getBirthDateStr());
    }
    
    @isTest
    public static void Beneficiary() {
        CMGADnDBasic.Beneficiary ben = new CMGADnDBasic.Beneficiary();
        CMGADnDBasic.Beneficiary ben2 = new CMGADnDBasic.Beneficiary('Test', 'Yes', 90, 'Test');
        Assert.areEqual(ben2.PrimaryIndicator, 'Primary');
        
        List<CMGADnDBasic.Beneficiary> beneficiaryList = new List<CMGADnDBasic.Beneficiary>();
        beneficiaryList.add(ben2);
        CMGADnDBasic.BeneficiaryList benList = new CMGADnDBasic.BeneficiaryList();
        CMGADnDBasic.BeneficiaryList benList2 = new CMGADnDBasic.BeneficiaryList(beneficiaryList);
    }
}