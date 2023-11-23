@isTest
public with sharing class CMGCommonTests {
    @isTest
	static void testCMGCommon() {
        List<CMGCommon.ApplicationStatusType> asts = new List<CMGCommon.ApplicationStatusType>();
		CMGCommon.ApplicationStatusType AST  = new CMGCommon.ApplicationStatusType();
        AST.StatusType='open';
        AST.StatusDateTime=system.now();
        AST.StatusReason='tstreason';
        asts.add(AST);
        
        List<CMGCommon.ApplicationType> cmgats = new List<CMGCommon.ApplicationType>();
		CMGCommon.ApplicationType AT = new CMGCommon.ApplicationType();
        AT.ApplicationConfirmationNumber=4;
        AT.ApplicationStatusList = asts;
        cmgats.add(AT);
        
        AT.ConsumerProductSummary =new CMGProductSummary.ConsumerProductSummaryType();
        AT.DocumentumID='6775';
        AT.ScanProcess='testsp';
        AT.OFSOrderNumber=33;
        
        AT.EmailAddress= new CMGPerson.EmailAddressType();
        List<CMGCommon.ConsumerMarketingAddressType> cmats = new List<CMGCommon.ConsumerMarketingAddressType>();
		CMGCommon.ConsumerMarketingAddressType CMAT = new CMGCommon.ConsumerMarketingAddressType();
        CMAT.MailableFlag=true;
        CMAT.PreferredFlag=false;
        cmats.add(CMAT);
        
        CMAT.EffectiveChangedAttribute=new CMGReusable.EffectiveChangedAttributeType();
		CMGCommon.ConsumerMarketingBaseSocialSecurityNumberType CMBSSNT = new CMGCommon.ConsumerMarketingBaseSocialSecurityNumberType();
		CMBSSNT.TaxId='testid';
        
        CMGCommon.ConsumerMarketingBirthDateType CMBDT = new CMGCommon.ConsumerMarketingBirthDateType();
		CMBDT.ChangedAttribute =new CMGReusable.ChangedAttributeType();
        CMGCommon.ConsumerMarketingDeathDateType CMDDT = new CMGCommon.ConsumerMarketingDeathDateType();
        CMDDT.DeathDate=system.today();
        
        CMDDT.ChangedAttribute =new CMGReusable.ChangedAttributeType();
		CMGCommon.ConsumerMarketingDeceasedFlagType CMDFT = new CMGCommon.ConsumerMarketingDeceasedFlagType();
		CMDFT.DeceasedIndicator=true;
        
        CMDFT.ChangedAttribute = new CMGReusable.ChangedAttributeType();
        CMGCommon.ConsumerMarketingDeceasedInformationType CMDIT = new CMGCommon.ConsumerMarketingDeceasedInformationType();
	    CMDIT.DeathDateInfo =new CMGCommon.ConsumerMarketingDeathDateType();
        CMDIT.DeceasedFlagInfo =new CMGCommon.ConsumerMarketingDeceasedFlagType();
        CMGCommon.ConsumerMarketingEmailAddressType CMEAT = new CMGCommon.ConsumerMarketingEmailAddressType();
		CMEAT.EffectiveChangedAttribute=new CMGReusable.EffectiveChangedAttributeType();
        CMGCommon.ConsumerMarketingGenderType CMGT = new CMGCommon.ConsumerMarketingGenderType();
        List<CMGCommon.ConsumerMarketingEmailAddressType> cmeats = new List<CMGCommon.ConsumerMarketingEmailAddressType>();
        cmeats.add(CMEAT);
        CMGT.GenderType='male';
        
        CMGT.ChangedAttribute= new CMGReusable.ChangedAttributeType();
		CMGT.getGenderCode();
		CMGT.setGenderCode(CMGCommon.ConsumerMarketingGenderType_GenderCode.MALE);
		CMGT.getGenderCode();
		CMGT.setGenderCode(CMGCommon.ConsumerMarketingGenderType_GenderCode.FEMALE);
		CMGT.getGenderCode();
		CMGT.setGenderCode(CMGCommon.ConsumerMarketingGenderType_GenderCode.UNKNOWN);
		CMGT.getGenderCode();
		CMGT.setGenderCode(CMGCommon.ConsumerMarketingGenderType_GenderCode.NEUTRAL);
		CMGT.getGenderCode();
        
		CMGCommon.ConsumerMarketingMaritalStatusType CMMST = new CMGCommon.ConsumerMarketingMaritalStatusType();
		CMMST.MaritalStatusCode='single';
        
        CMGAddress.CommonAddressType cmgcat = new CMGAddress.CommonAddressType();
        List<CMGAddress.CommonAddressType> cmgcats = new List<CMGAddress.CommonAddressType>();
        cmgcats.add(cmgcat);
        CMMST.ChangedAttribute=new CMGReusable.ChangedAttributeType();
        CMGCommon.ConsumerMarketingMatchPersonType CMMPT = new CMGCommon.ConsumerMarketingMatchPersonType();
		CMMPT.PersonName =new CMGPerson.PersonNameType();
        CMMPT.TaxId='779';
        CMMPT.BirthDate=system.today();
        CMMPT.BirthDatestr='tstbd';
        CMMPT.AddressList = cmgcats;
        
        CMMPT.Organization =new CMGReusable.OrganizationType();    
        CMGCommon.ConsumerMarketingPersonNameType CMPNT = new CMGCommon.ConsumerMarketingPersonNameType();
            
		CMPNT.EffectiveChangedAttribute = new CMGReusable.EffectiveChangedAttributeType();
        
        List<CMGCommon.ConsumerMarketingPhoneType> cmgmpts = new List<CMGCommon.ConsumerMarketingPhoneType>();
        CMGCommon.ConsumerMarketingPhoneType CMPhT = new CMGCommon.ConsumerMarketingPhoneType();
        CMPhT.EffectiveChangedAttribute = new CMGReusable.EffectiveChangedAttributeType ();
		CMGCommon.ConsumerMarketingSocialSecurityNumberType CMSSNT = new CMGCommon.ConsumerMarketingSocialSecurityNumberType();
		CMSSNT.SocialSecurityNumberType = CMSSNT.TaxIdLastFour='tstid';
        cmgmpts.add(CMPhT);
        
        CMGCommon.ConsumerMarketingPersonType CMPT = new CMGCommon.ConsumerMarketingPersonType();
        CMPT.PersonId='testpid';
        CMPT.AddressList = cmats;
        CMPT.PhoneList = cmgmpts;
        CMPT.EmailAddressList = cmeats;
        
        CMPT.ConsumerMarketingPersonName= new CMGCommon.ConsumerMarketingPersonNameType();
        CMPT.SocialSecurityNumberInformation =new   CMGCommon.ConsumerMarketingSocialSecurityNumberType();
        CMPT.BirthDateInformation =new CMGCommon.ConsumerMarketingBirthDateType();
        CMPT.Gender= new CMGCommon.ConsumerMarketingGenderType();
        CMPT.MaritalStatus=new CMGCommon.ConsumerMarketingMaritalStatusType();
        CMPT.DeceasedInformation=new CMGCommon.ConsumerMarketingDeceasedInformationType();
        
        CMSSNT.ChangedAttribute =new CMGReusable.ChangedAttributeType();
        CMGCommon.ConsumerProfileType CPT = new CMGCommon.ConsumerProfileType();
		CMGCommon.ErrorType ET = new CMGCommon.ErrorType();
		CMGCommon.MarketingOptOutType MOOT = new CMGCommon.MarketingOptOutType();
		MOOT.OptOutDate = date.today();
		system.debug(MOOT.OptOutDate);
		MOOT.Reason = 1;
		system.debug(MOOT.Reason);
		MOOT.OptOutDateStr = '12/27/2009';
		system.debug(MOOT.OptOutDateStr);
		system.debug(MOOT.ReasonEnum);
        MOOT.UserId = '1111111';
		MOOT.ReasonEnum = CMGCommon.MarketingOptOutType_Reason.REQUESTED;
		system.debug(MOOT.ReasonEnum);
        
        CMGReusable.OrganizationType cmgot = new CMGReusable.OrganizationType();
        cmgot.ContractNumber = '11111';
        cmgot.OrganizationId = '11111';
        cmgot.OrganizationSegment = 'test';
        cmgot.CreditUnion = 'test cu';
        
        List<CMGCommon.SuppressionType> cmgsts = new List<CMGCommon.SuppressionType>();
		CMGCommon.MembershipType MT = new CMGCommon.MembershipType();
		CMGCommon.SourceRecordType SRT = new CMGCommon.SourceRecordType();
		CMGCommon.SuppressionType ST = new CMGCommon.SuppressionType();
		ST.Channel = 2;
		Assert.areEqual(ST.Channel,2);
		ST.Reason = 1;
		Assert.areEqual(ST.Reason,1);
		ST.Source = 1;
		Assert.areEqual(ST.Source,1);
		ST.BeginDate = date.today();
		Assert.areEqual(ST.BeginDate,Date.today());
		ST.EndDate = date.today();
		Assert.areEqual(ST.EndDate,Date.today());
		ST.BeginDateStr = '12/27/2009';
		Assert.areEqual(ST.BeginDateStr,'12/27/2009');
		ST.EndDateStr = '12/27/2009';
		Assert.areEqual(ST.EndDateStr,'12/27/2009');
		ST.ChannelEnum = CMGCommon.SuppressionType_Channel.EMAIL;
		Assert.areEqual(ST.ChannelEnum,CMGCommon.SuppressionType_Channel.EMAIL);
		ST.ReasonEnum = CMGCommon.SuppressionType_Reason.AUTO;
		Assert.areEqual(ST.ReasonEnum,CMGCommon.SuppressionType_Reason.AUTO);
		ST.SourceEnum = CMGCommon.SuppressionType_Source.ADD;
		Assert.areEqual(ST.SourceEnum,CMGCommon.SuppressionType_Source.ADD);
        ST.UserId = '111111';
        ST.Organization = cmgot;
        cmgsts.add(ST);
        
        CMGCommon.ErrorType errt = new CMGCommon.ErrorType();
        et.ErrorCode = 200;
        et.ErrorMessage = 'test';
        
        List<CMGCommon.SourceRecordType> cmgsrts = new List<CMGCommon.SourceRecordType>();
        CMGCommon.SourceRecordType cmgsrt = new CMGCommon.SourceRecordType();
        cmgsrt.UniqueId = 1111;
        cmgsrt.SourceSystemId = '1111';
        cmgsrt.SourceSystemKey = '1111';
        cmgsrt.Organization = cmgot;
        cmgsrts.add(cmgsrt);
        
        /*CMGFinancialAccount.FinancialAccountType cmgfat = new CMGFinancialAccount.FinancialAccountType();
        List<CMGFinancialAccount.FinancialAccountType> cmgfats = new List<CMGFinancialAccount.FinancialAccountType>();
        cmgfats.add(cmgfat);*/
        
        List<CMGCommon.MembershipType> cmgmts = new List<CMGCommon.MembershipType>();
        CMGCommon.MembershipType cmgmt = new CMGCommon.MembershipType();
        cmgmt.EnrollmentDate = Date.today();
        cmgmt.MembershipType = 'test';
        cmgmt.Organization = cmgot;
        cmgmt.TerminationDate = Date.today();
        //cmgmt.FinancialAccountList = cmgfats;
        cmgmts.add(cmgmt);
        
        CMGProductSummary.ConsumerProductSummaryType cmgcpst = new CMGProductSummary.ConsumerProductSummaryType();
        CMGContactHistory.ContactInteractionHistoryType cmgciht = new CMGContactHistory.ContactInteractionHistoryType();
        List<CMGProductSummary.ConsumerProductSummaryType> cmgcpsts = new List<CMGProductSummary.ConsumerProductSummaryType>();
        cmgcpsts.add(cmgcpst);
        CMGCommon.ConsumerProfileType cmgcpt = new CMGCommon.ConsumerProfileType();
        cmgcpt.ConsumerMarketingPerson = CMPT;
        cmgcpt.MembershipList = cmgmts;
        cmgcpt.MarketingOptOut = MOOT;
        cmgcpt.ConsumerProductSummaryList = cmgcpsts;
        cmgcpt.ApplicationList = cmgats;
        cmgcpt.SuppressionList = cmgsts;
        cmgcpt.SourceRecordList = cmgsrts;
        cmgcpt.ContactInteractionHistory = cmgciht;
	}
}