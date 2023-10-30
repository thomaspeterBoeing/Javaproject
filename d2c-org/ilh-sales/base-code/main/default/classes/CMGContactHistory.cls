/***
Copyright: CUNA Mutual Group
Purpose: ContactHistory classes to support interactions with the webservice
1.0 - Mark Pond - 7/18/2013 - Created
***/
public class CMGContactHistory {
    
    public class AgentDisclosureType {
        public AgentType Agent { get; set; }
        public RespondentType Respondent { get; set; }
        public boolean ExistingInsuranceFlag { get; set; }
        public boolean ReplacePolicyFlag { get; set; }
        public decimal CoverageAmount { get; set; }
        public string ResidenceState { get; set; }
        public string SalesMaterialsUsed { get; set; }
        public string ReplacementReason { get; set; }
        public string SpecialInstructions { get; set; }
        public Date ConversationDate { get; set; }
    }
    
    public class AgentType extends CMGPerson.PersonNameType {
        public string AgentId { get; set; }
    }
    
    public virtual class CampaignContactInteractionType extends ContactInteractionType {
        public CampaignType Campaign { get; set; }
        public CampaignDetailsType CampaignDetails { get; set; }
        public CampaignContactOfferType CampaignContactOffer { get; set; }
        public String ProductNumber { get; set; }
        public Boolean IsFollowUp { get; set; }
    }
    
    public class CampaignContactOfferType extends ContactOfferType {
        public CampaignOfferType CampaignOffer { get; set; }
        public CampaignKitType CampaignKit { get; set; }
        public CampaignProductType CampaignProduct { get; set; }    
    }
    
    public class CampaignDetailsType {
        public string BillingLanguageIndicator { get; set; }
        public Date DropDate { get; set; }
        public Date ReplyByDate { get; set; }
    }
    
    public class CampaignKitType {
        public string Description { get; set; }
        public string Code { get; set; }
    }
    
    public class CampaignOfferType {
        public string OfferDescription { get; set; }
        public string Version { get; set; }
        public string VersionDescription { get; set; }
        public string Code { get; set; }
        public string OfferType { get; set; }
        public boolean ExcludeLifeUpgradeProcessFlag { get; set; }
    }
        
    public class CampaignProductType {
        public string OFSProductCode { get; set; }
        public string OFSApplicationCode { get; set; }
        public string Description { get; set; }
        public string Code { get; set; }
    }
    
    public class CampaignType { 
        public string CampaignType { get; set; }    
        public string Description { get; set; } 
        public string Code { get; set; }    
        public string GroupName { get; set; }
        public Date CampaignStartDate { get; set; }
    }
    
    public class ConsumerSalesContactInteractionType extends PhoneContactInteractionType {
        public ConsumerSalesOfferType ConsumerSalesOffer { get; set; }
    }   
    
    public class ConsumerSalesOfferType extends ContactOfferType {
        public AgentDisclosureType AgentDisclosure { get; set; }
        public PolicyDetailsType PolicyDetails { get; set; }
    }
    
    public virtual class ContactInteractionType {
        public integer ContactInteractionType { get; set; }
        public string ContactInteractionID { get; set; }
        public string ContactSourceID { get; set; }
        public string Description { get; set; }
        public ContactStatusInfoType ContactStatusInfo { get; set; }
        public string ContentLink { get; set; }
        public ContactPersonType ContactPerson { get; set; }
        public CMGReusable.OrganizationType Organization { get; set; }
        
        public ContactInteractionType_ContactInteractionTypeCode getTypeCode() {
            if (ContactInteractionType == 0){return ContactInteractionType_ContactInteractionTypeCode.DIRECTMAIL;}  
            if (ContactInteractionType == 1){return ContactInteractionType_ContactInteractionTypeCode.INBOUNDPHONE;}   
            if (ContactInteractionType == 2){return ContactInteractionType_ContactInteractionTypeCode.OUTBOUNDPHONE;}  
            if (ContactInteractionType == 3){return ContactInteractionType_ContactInteractionTypeCode.EMAIL;}
            if (ContactInteractionType == 4){return ContactInteractionType_ContactInteractionTypeCode.WEBVISIT;}
            if (ContactInteractionType == 5){return ContactInteractionType_ContactInteractionTypeCode.TERMLIFECONVERSION;}
            if (ContactInteractionType == 6){return ContactInteractionType_ContactInteractionTypeCode.TRANSPROMOSTATEMENTSTUFFER;}    
            return null;
        }
        public void setInteractionType(Integer val) {
            ContactInteractionType = val; 
        }
    }
    
    public virtual class ContactOfferType {
        public string Status { get; set; }
        public string InsuranceProductCode { get; set; }
    }
    
    public class ContactPersonType extends CMGPerson.SimplePersonType {
        public string WealthCode { get; set; }
        public string IncomeRange { get; set; }
        public string personRole { get; set; }
    }
    
    public class ConversionLetterDetailsType {
        public string LetterName { get; set; }
        public Date CreateDate { get; set; }
    }
    
    public class DirectMailCampaignContactInteractionType extends CampaignContactInteractionType {
        public CMGAddress.CommonAddressType CommonAddress { get; set; }
    }
    
    public virtual class DirectMailContactInteractionType extends ContactInteractionType {
        public DirectMailOfferType DirectMailOffer { get; set; }    
    }
        
    public virtual class DirectMailOfferType extends ContactOfferType {
        public PolicyDetailsType PolicyDetails { get; set; }
        public ConversionLetterDetailsType ConversionLetterDetails { get; set; }
    }
    
    public class DispositionType {
        public string Code { get; set; }
        public string Description { get; set; }
    }
    
    public class EmailCampaignContactInteractionType extends CampaignContactInteractionType {
        public EmailAddressType EmailAddress { get; set; }
    }
    
    public class PhoneCampaignContactInteractionType extends CampaignContactInteractionType {
        public CMGPerson.PhoneType Phone { get; set; }
        public DispositionType Disposition { get; set; }
    }
    
    public virtual class PhoneContactInteractionType extends ContactInteractionType {
        public CMGPerson.PhoneType Phone { get; set; }
        public DispositionType Disposition { get; set; }    
    }
    
    public class PolicyDetailsType { 
        public string PolicyNumber { get; set; }
        public Date IssueDate { get; set; }
        public decimal ModePremiumAmount { get; set; }
        public String BillingMethod { get; set; }
        public String BillingFrequency { get; set; }
    }
    
    public class RespondentType extends CMGPerson.PersonNameType {
        public string Relationship { get; set; }
    }
    
    public class TermLifeConversionContactInteractionType extends DirectMailContactInteractionType {
        // this space intentionally left blank  
    }
    
    public class TermLifeConversionOfferType extends DirectMailOfferType {
        public ConversionLetterDetailsType ConversionLetterDetails { get; set; }    
    }
    
    public class ContactInteractionHistoryType {
        public List<DirectMailCampaignContactInteractionType> DirectMailCampaignContactInteractionList { get; set; }
        public List<DirectMailContactInteractionType> DirectMailContactInteractionList { get; set; }
        public List<EmailCampaignContactInteractionType> EmailCampaignContactInteractionList { get; set; }
        public List<PhoneCampaignContactInteractionType> PhoneCampaignContactInteractionList { get; set; }
        public List<PhoneContactInteractionType> PhoneContactInteractionList { get; set; }
    }
    
    public enum ContactInteractionType_ContactInteractionTypeCode {
        DIRECTMAIL,
        INBOUNDPHONE,
        OUTBOUNDPHONE,
        EMAIL,
        WEBVISIT,
        TERMLIFECONVERSION,
        TRANSPROMOSTATEMENTSTUFFER
    }
    
    public class EmailAddressType {
        public string Value { get; set; }
    }
    
    public class ContactStatusInfoType {
        public string status { get; set; }
        public string statusdatetime { get; set; }
    }
    
}