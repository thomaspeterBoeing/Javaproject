@isTest
public with sharing class CMGProductSummaryTests {
    @isTest
	static void testCMGProductSummary() {
        CMGReusable.OrganizationType OT = new CMGReusable.OrganizationType();
        OT.ContractNumber = '1111';
        OT.CreditUnion = 'CU';
        OT.OrganizationId = '1111';
        OT.OrganizationSegment = 'test';
        
		CMGProductSummary.ConsumerProductSummaryType CPST = new CMGProductSummary.ConsumerProductSummaryType();
        CPST.Organization = OT;
        
		CMGProductSummary.CoverageInformationType CIT = new CMGProductSummary.CoverageInformationType();
		CIT.CoverageAmount=25000;
  		CIT.CoverageType='WP';
        
		CMGProductSummary.ProductSummaryType PST = new CMGProductSummary.ProductSummaryType();
		PST.SourceSystemProductKey='s1';
        PST.Status='Active';
        PST.CommonStatus='CommonActive';
        PST.EffectiveDate=date.today();
        PST.TerminationDate=date.today();
        PST.CoverageInformation = CIT;
        
		CMGProductSummary.SimpleProductSummaryType SPST = new CMGProductSummary.SimpleProductSummaryType();
        SPST.SourceSystemId='ADD';
        SPST.ProductNumber='0';
        SPST.ProductRelationship=12345;
	}
}