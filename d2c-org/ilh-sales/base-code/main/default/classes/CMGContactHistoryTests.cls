@isTest
public with sharing class CMGContactHistoryTests {
	static testMethod void testCMGContactHistory() {
		CMGContactHistory.AgentDisclosureType ADT = new CMGContactHistory.AgentDisclosureType();
		ADT.Agent =new CMGContactHistory.AgentType();
		ADT.Respondent= new CMGContactHistory.RespondentType();
		ADT.ExistingInsuranceFlag = false;
		ADT.ReplacePolicyFlag= true;
		ADT.CoverageAmount=30000.00; 
		ADT.ResidenceState='State';
		ADT.SalesMaterialsUsed='Yes';
		ADT.ReplacementReason='Test';
		ADT.SpecialInstructions='Yes';
		ADT.ConversationDate=System.today();
        
		CMGContactHistory.AgentType AT = new CMGContactHistory.AgentType();
		AT.AgentId='TestAgent';
        
		CMGContactHistory.CampaignContactInteractionType CCIT = new CMGContactHistory.CampaignContactInteractionType();
		CCIT.Campaign= new CMGContactHistory.CampaignType();
		CCIT.CampaignDetails = new CMGContactHistory.CampaignDetailsType();
		CCIT.CampaignContactOffer = new CMGContactHistory.CampaignContactOfferType();
		CCIT.ProductNumber='12345';
		CCIT.IsFollowUp=true;
        
		CMGContactHistory.CampaignContactOfferType CCOT = new CMGContactHistory.CampaignContactOfferType();
		CCOT.CampaignOffer = new CMGContactHistory.CampaignOfferType();
		CCOT.CampaignKit = new CMGContactHistory.CampaignKitType();
		CCOT.CampaignProduct = new CMGContactHistory.CampaignProductType();
		CMGContactHistory.CampaignDetailsType CDT = new CMGContactHistory.CampaignDetailsType();
		CDT.BillingLanguageIndicator='1234';
		CDT.DropDate= system.Today();
		CDT.ReplyByDate = system.today()+1;
        
		CMGContactHistory.CampaignKitType CKT = new CMGContactHistory.CampaignKitType();
		CKT.Description='Test';
		CKT.Code='Test123';
        
		CMGContactHistory.CampaignOfferType COT = new CMGContactHistory.CampaignOfferType();
		COT.OfferDescription='TestOffer';
		COT.Version='V1';
		COT.VersionDescription='FirstTest';
		COT.Code='1234';
		COT.OfferType='Test';
		COT.ExcludeLifeUpgradeProcessFlag= true;
        
		CMGContactHistory.CampaignProductType CPT = new CMGContactHistory.CampaignProductType();
		CPT.OFSProductCode='Test001';
		CPT.OFSApplicationCode='TestApp001';
		CPT.Description='Test';
		CPT.Code='12345';
        
		CMGContactHistory.CampaignType CT = new CMGContactHistory.CampaignType();
		CT.CampaignType='TestCampaign';
		CT.Description='Testing';
		CT.Code='1234';
		CT.GroupName='Test';
		CT.CampaignStartDate=System.today()-5;
        
		CMGContactHistory.ConsumerSalesContactInteractionType CSCIT = new CMGContactHistory.ConsumerSalesContactInteractionType();
		CSCIT.ConsumerSalesOffer = new CMGContactHistory.ConsumerSalesOfferType();
		CMGContactHistory.ConsumerSalesOfferType CSOT = new CMGContactHistory.ConsumerSalesOfferType();
		CSOT.AgentDisclosure = new CMGContactHistory.AgentDisclosureType();
		CSOT.PolicyDetails = new CMGContactHistory.PolicyDetailsType();
		CMGContactHistory.ContactInteractionHistoryType CIHT = new CMGContactHistory.ContactInteractionHistoryType();
		CMGContactHistory.ContactInteractionType CIT = new CMGContactHistory.ContactInteractionType();
		CIT.ContactInteractionID ='Test001';
		CIT.ContactSourceID='Test001';
		CIT.Description='Testing';
        
		CIT.ContactStatusInfo = new CMGContactHistory.ContactStatusInfoType();
		CIT.ContentLink ='test';
        
		CIT.ContactPerson = new CMGContactHistory.ContactPersonType();
		CIT.Organization = new CMGReusable.OrganizationType();
        Assert.isNull(CIT.getTypeCode());
		CIT.setInteractionType(0);
        Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.DIRECTMAIL);
		CIT.setInteractionType(1);
		Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.INBOUNDPHONE);
		CIT.setInteractionType(2);
		Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.OUTBOUNDPHONE);
		CIT.setInteractionType(3);
		Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.EMAIL);
		CIT.setInteractionType(4);
		Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.WEBVISIT);
		CIT.setInteractionType(5);
		Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.TERMLIFECONVERSION);
		CIT.setInteractionType(6);
		Assert.areEqual(CIT.getTypeCode(), CMGContactHistory.ContactInteractionType_ContactInteractionTypeCode.TRANSPROMOSTATEMENTSTUFFER);
        
		CMGContactHistory.ContactOfferType CntOT = new CMGContactHistory.ContactOfferType();
		CntOT.Status='Test';
		CntOT.InsuranceProductCode='1234';
        
		CMGContactHistory.ContactPersonType CntPT = new CMGContactHistory.ContactPersonType();
		CntPT.WealthCode='123';
		CntPT.IncomeRange='30,000';
		CntPT.personRole='SE';
        
		CMGContactHistory.ConversionLetterDetailsType CLDT = new CMGContactHistory.ConversionLetterDetailsType();
		CLDT.LetterName='Test';
		CLDT.CreateDate= system.today();
        
		CMGContactHistory.DirectMailCampaignContactInteractionType DMCCIT = new CMGContactHistory.DirectMailCampaignContactInteractionType();
		DMCCIT.CommonAddress = new CMGAddress.CommonAddressType();
		CMGContactHistory.DirectMailContactInteractionType DMCIT = new CMGContactHistory.DirectMailContactInteractionType();
		DMCIT.DirectMailOffer = new CMGContactHistory.DirectMailOfferType();
		CMGContactHistory.DirectMailOfferType DMOT = new CMGContactHistory.DirectMailOfferType();
		DMOT.PolicyDetails= new CMGContactHistory.PolicyDetailsType();
		DMOT.ConversionLetterDetails = new CMGContactHistory.ConversionLetterDetailsType();
		CMGContactHistory.DispositionType DT = new CMGContactHistory.DispositionType();
		DT.Code='1234';
		DT.Description='Test';
        
		CMGContactHistory.EmailCampaignContactInteractionType ECCIT = new CMGContactHistory.EmailCampaignContactInteractionType();
		ECCIT.EmailAddress = new CMGContactHistory.EmailAddressType();
        
		CMGContactHistory.PhoneCampaignContactInteractionType PCCIT = new CMGContactHistory.PhoneCampaignContactInteractionType();
		PCCIT.Phone   = new CMGPerson.PhoneType();
		PCCIT.Disposition = new CMGContactHistory.DispositionType();
		CMGContactHistory.PhoneContactInteractionType PCIT = new CMGContactHistory.PhoneContactInteractionType();
		PCIT.Phone = new CMGPerson.PhoneType();
		PCIT.Disposition = new CMGContactHistory.DispositionType();
		CMGContactHistory.PolicyDetailsType PDT = new CMGContactHistory.PolicyDetailsType();
		PDT.PolicyNumber='1234';
		PDT.IssueDate=system.today();
		PDT.ModePremiumAmount= 3000.00;
		PDT.BillingMethod='Online';
		PDT.BillingFrequency='4';
        
		CMGContactHistory.RespondentType RT = new CMGContactHistory.RespondentType();
		RT.Relationship='Test';
        
		CMGContactHistory.TermLifeConversionContactInteractionType TLCCIT = new CMGContactHistory.TermLifeConversionContactInteractionType();
		CMGContactHistory.TermLifeConversionOfferType TLCOT = new CMGContactHistory.TermLifeConversionOfferType();
		TLCOT.ConversionLetterDetails = new CMGContactHistory.ConversionLetterDetailsType();
		CMGContactHistory.EmailAddressType EAT = new CMGContactHistory.EmailAddressType();
		EAT.Value='123';
        
		CMGContactHistory.ContactStatusInfoType CSI = new CMGContactHistory.ContactStatusInfoType();
		CSI.status='123';
		CSI.statusdatetime='test123';
        
        CMGContactHistory.ContactInteractionHistoryType cihist = new CMGContactHistory.ContactInteractionHistoryType();
        List<CMGContactHistory.DirectMailCampaignContactInteractionType> dmccits = new List<CMGContactHistory.DirectMailCampaignContactInteractionType>();
        List<CMGContactHistory.DirectMailContactInteractionType> dmcits = new List<CMGContactHistory.DirectMailContactInteractionType>();
        List<CMGContactHistory.EmailCampaignContactInteractionType> eccits = new List<CMGContactHistory.EmailCampaignContactInteractionType>();
        List<CMGContactHistory.PhoneCampaignContactInteractionType> pccits = new List<CMGContactHistory.PhoneCampaignContactInteractionType>();
        List<CMGContactHistory.PhoneContactInteractionType> pcits = new List<CMGContactHistory.PhoneContactInteractionType>();
        
        dmccits.add(DMCCIT);
        dmcits.add(DMCIT);
        eccits.add(ECCIT);
        pccits.add(PCCIT);
        pcits.add(PCIT);
        
        cihist.DirectMailCampaignContactInteractionList = dmccits;
        cihist.DirectMailContactInteractionList = dmcits;
        cihist.EmailCampaignContactInteractionList = eccits;
        cihist.PhoneCampaignContactInteractionList = pccits;
        cihist.PhoneContactInteractionList = pcits;
	}
}