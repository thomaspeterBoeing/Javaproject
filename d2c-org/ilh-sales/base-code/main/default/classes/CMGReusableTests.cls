@isTest
public with sharing class CMGReusableTests {
    @isTest
	static void testCMGAReusable() {
		CMGReusable.EffectiveChangedAttributeType ECAT = new CMGReusable.EffectiveChangedAttributeType();
		ECAT.EffectiveDateTime=date.today();
		ECAT.EndDateTime=date.today();
        
		CMGReusable.GeographicInfoType GIT = new CMGReusable.GeographicInfoType();
		GIT.Latitude='150';
		GIT.Longitute='150';
        
		CMGReusable.OrganizationType OT = new CMGReusable.OrganizationType();
		OT.ContractNumber='12345';
		OT.OrganizationId='1234';
		OT.OrganizationSegment='OSeen';
        OT.CreditUnion = 'CU';
        
		CMGReusable.ValidationInfoType VIT = new CMGReusable.ValidationInfoType();
		VIT.UserId='12345';
		VIT.ValidationDateTime=date.today();
        
        CMGReusable.CreationInfoType CIT = new CMGReusable.CreationInfoType();
		CIT.CreationDateTime=date.today();
		CIT.SourceSystemId='1';
		CIT.SourceSystemKey='123';
        CIT.Organization = OT;
        
        CMGReusable.ChangedAttributeType CAT = new CMGReusable.ChangedAttributeType();
        CAT.ValidationInfo = VIT;
        CAT.CreationInfo = CIT;
	}
}