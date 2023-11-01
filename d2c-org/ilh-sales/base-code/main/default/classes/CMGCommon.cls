public class CMGCommon {
    
    public class ApplicationStatusType {
        public String StatusType                                                                    { get; set; }
        public DateTime StatusDateTime                                                              { get; set; }
        public String StatusReason                                                                  { get; set; }
    }
    
    public class ApplicationType {
        public Integer ApplicationConfirmationNumber { get; set; }
        public CMGProductSummary.ConsumerProductSummaryType ConsumerProductSummary { get; set; }
        public String DocumentumID { get; set; }
        public String ScanProcess { get; set; }
        public Integer OFSOrderNumber { get; set; }
        public List<ApplicationStatusType> ApplicationStatusList { get; set; }
        public CMGPerson.EmailAddressType EmailAddress { get; set; }
    }
    
    public class ConsumerMarketingAddressType extends CMGAddress.StandardizedAddressType {
        public boolean MailableFlag { get; set; }
        public boolean PreferredFlag { get; set; }
        public CMGReusable.EffectiveChangedAttributeType EffectiveChangedAttribute { get; set; }
    }
    
    public virtual class ConsumerMarketingBaseSocialSecurityNumberType {
        public string TaxId { get; set; }   
    }
     
    public class ConsumerMarketingBirthDateType extends CMGPerson.BirthDateInfoType {
        public CMGReusable.ChangedAttributeType ChangedAttribute { get; set; }  
    } 
    
    public class ConsumerMarketingDeathDateType {
        public Date DeathDate { get; set; }
        public CMGReusable.ChangedAttributeType ChangedAttribute { get; set; }
    }
    
    public class ConsumerMarketingDeceasedFlagType {
        public boolean DeceasedIndicator { get; set; }
        public CMGReusable.ChangedAttributeType ChangedAttribute { get; set; }
    }
    
    public class ConsumerMarketingDeceasedInformationType {
        public ConsumerMarketingDeathDateType DeathDateInfo { get; set; }
        public ConsumerMarketingDeceasedFlagType DeceasedFlagInfo { get; set; }
    }
    
    public class ConsumerMarketingEmailAddressType extends CMGPerson.CompleteEmailAddressType {
        public CMGReusable.EffectiveChangedAttributeType EffectiveChangedAttribute { get; set; }
    }
    
    public enum ConsumerMarketingGenderType_GenderCode {
        MALE,
        FEMALE,
        UNKNOWN,
        NEUTRAL
    }
    
    public class ConsumerMarketingGenderType {
        public string GenderType { get; set; }
        public integer GenderCode { get; set; } 
        public CMGReusable.ChangedAttributeType ChangedAttribute { get; set; }
        public ConsumerMarketingGenderType_GenderCode getGenderCode() {
            if (genderCode == 0)
                return ConsumerMarketingGenderType_GenderCode.MALE;
            if (genderCode == 1)
                return ConsumerMarketingGenderType_GenderCode.FEMALE;
            if (genderCode == 2)
                return ConsumerMarketingGenderType_GenderCode.UNKNOWN;
            if (genderCode == 3)
                return ConsumerMarketingGenderType_GenderCode.NEUTRAL;
            return null;
        }
        public void setGenderCode(ConsumerMarketingGenderType_GenderCode val) {
            if (val == ConsumerMarketingGenderType_GenderCode.MALE)
                GenderCode = 0;
            if (val == ConsumerMarketingGenderType_GenderCode.FEMALE)
                GenderCode = 1;
            //The following two situations shouldn't even happen since SF does not allow the option of Unknown or Neutral
            if (val == ConsumerMarketingGenderType_GenderCode.UNKNOWN)
                GenderCode = 2;
            if (val == ConsumerMarketingGenderType_GenderCode.NEUTRAL)
                GenderCode = 3;
        }
    }
    
    public class ConsumerMarketingMaritalStatusType {
        public string MaritalStatusCode { get; set; }
        public CMGReusable.ChangedAttributeType ChangedAttribute { get; set; }
    }
    
    public class ConsumerMarketingMatchPersonType {
        public CMGPerson.PersonNameType PersonName { get; set; }
        public List<CMGAddress.CommonAddressType> AddressList { get; set; }
        public string TaxId { get; set; }
        public Date BirthDate { get; set; }
        public string BirthDatestr { get; set;}
        public CMGReusable.OrganizationType Organization { get; set; }
    }
    
    public class ConsumerMarketingPersonNameType extends CMGPerson.PersonNameType {
        public CMGReusable.EffectiveChangedAttributeType EffectiveChangedAttribute { get; set; }
    } 
    
    public class ConsumerMarketingPersonType {
        public String PersonId { get; set; }
        public ConsumerMarketingPersonNameType ConsumerMarketingPersonName { get; set; }
        public List<ConsumerMarketingAddressType> AddressList { get; set; }
        public ConsumerMarketingSocialSecurityNumberType SocialSecurityNumberInformation { get; set; }
        public ConsumerMarketingBirthDateType BirthDateInformation { get; set; }
        public List<ConsumerMarketingPhoneType> PhoneList { get; set; }
        public List<ConsumerMarketingEmailAddressType> EmailAddressList { get; set; }
        public ConsumerMarketingGenderType Gender { get; set; }
        public ConsumerMarketingMaritalStatusType MaritalStatus { get; set; }
        public ConsumerMarketingDeceasedInformationType DeceasedInformation { get; set; }
    }
    
    public class ConsumerMarketingPhoneType extends CMGPerson.PhoneType {
        public CMGReusable.EffectiveChangedAttributeType EffectiveChangedAttribute { get; set; }
    }
    
    public class ConsumerMarketingSocialSecurityNumberType extends ConsumerMarketingBaseSocialSecurityNumberType {
        public string SocialSecurityNumberType { get; set; }
        public string TaxIdLastFour { get; set; }
        public CMGReusable.ChangedAttributeType ChangedAttribute { get; set; }
    }
    
    public class ConsumerProfileType {
        public ConsumerMarketingPersonType ConsumerMarketingPerson { get; set; }
        public List<MembershipType> MembershipList { get; set; }
        public List<CMGProductSummary.ConsumerProductSummaryType> ConsumerProductSummaryList { get; set; }
        public List<ApplicationType> ApplicationList { get; set; }
        public List<SuppressionType> SuppressionList { get; set; }      
        public MarketingOptOutType MarketingOptOut { get; set; }
        public List<SourceRecordType> SourceRecordList { get; set; }
        public CMGContactHistory.ContactInteractionHistoryType ContactInteractionHistory { get; set; }
    }
    
    public class ErrorType {
        public integer ErrorCode { get; set; }
        public string ErrorMessage { get; set; }
    }
    
    public class MarketingOptOutType {
        public Date pvtOptOutDate;
        public Integer pvtReason;

        public String UserId { get; set; }
        public Date OptOutDate { 
            get{return pvtOptOutDate;}
            set{pvtOptOutDate = value;} 
        }
        public Integer Reason { 
            get{return pvtReason;}
            set{pvtReason = value;} 
        }
        
        public String OptOutDateStr {
            get{return CMGCommon.getDateString(this.pvtOptOutDate);}
            set{if(value != '' && value != null) this.pvtOptOutDate = Date.parse(value);}
        }
        public MarketingOptOutType_Reason ReasonEnum {
            get
            {
                if(this.pvtReason == null){return null;}
                return MarketingOptOutType_Reason.values()[this.pvtReason];
            }
            set{this.pvtReason = Value.ordinal();}
        }
    }
    
    public enum MarketingOptOutType_Reason{NONE,REQUESTED,CA_BOTH_COMPANY_TYPES,CA_COMPANIES_WE_OWN,CA_OTHER_COMPANIES,OPT_IN_STATE_INS_ONLY}

    
    
    public class MembershipType {
        public String MembershipType { get; set; }
        public CMGReusable.OrganizationType Organization { get; set; }
        public Date EnrollmentDate { get; set; }
        public Date TerminationDate { get; set; }
        public List<CMGFinancialAccount.FinancialAccountType> FinancialAccountList { get; set; }  
    }
    
    public class SourceRecordType {
        public Integer UniqueId { get; set; }
        public String SourceSystemId { get; set; }
        public String SourceSystemKey { get; set; }
        public CMGReusable.OrganizationType Organization { get; set; }
    }
    
    public class SuppressionType {
        private Integer pvtChannel;
        private Integer pvtReason;
        private Integer pvtSource;
        private Date pvtBeginDate;
        private Date pvtEndDate;
        
        public Integer Channel { 
            get{return pvtChannel;}
            set{pvtChannel = value;} 
        }
        public Integer Reason { 
            get{return pvtReason;}
            set{pvtReason = value;} 
        }
        public Integer Source { 
            get{return pvtSource;}
            set{pvtSource = value;} 
        }
        public Date BeginDate { 
            get{return pvtBeginDate;}
            set{pvtBeginDate = value;} 
        }
        public Date EndDate { 
            get{return pvtEndDate;}
            set{pvtEndDate = value;} 
        }
        public String UserId { get; set; }
        public CMGReusable.OrganizationType Organization { get; set; }
        
        public String BeginDateStr{
            get{return CMGCommon.getDateString(this.pvtBeginDate);}
            set{if(value != '') this.pvtBeginDate = Date.parse(value);}
        }

        public String EndDateStr{
            get{return CMGCommon.getDateString(this.EndDate);}
            set{if(!(value == '' || value == '12/31/9999')) this.EndDate = Date.parse(value);}
        }
        
        public SuppressionType_Channel ChannelEnum {
            get
            {
                if(this.pvtChannel == null){return null;}
                return SuppressionType_Channel.values()[this.pvtChannel];
            }
            set{ this.pvtChannel = value.ordinal(); }
        }
        
        public SuppressionType_Reason ReasonEnum {
            get
            {
                if(this.pvtReason == null){return null;}
                return SuppressionType_Reason.values()[this.pvtReason];
            }
            set{ this.pvtReason = Value.ordinal(); }
        }

        public SuppressionType_Source SourceEnum {
            get
            {
                if(this.pvtSource == null){return null;}
                return SuppressionType_Source.values()[this.pvtSource];
            }
            set{ this.pvtSource = Value.ordinal(); }
        }
        
    }
    public Enum SuppressionType_Channel {NONE,MAIL, PHONE, EMAIL}
    public Enum SuppressionType_Reason {REQUESTED, DECEASED, AUTO, TAKEOVER, OTHER,PREDICTIVELOANGROWTH}
    public Enum SuppressionType_Source {NONE,ADD, CREDITUNIONBATCH, DIRECTMARKETINGASSOCIATION, 
        LIBERTYMUTUAL, LIFE70, LIFECOM, LIFEPRO, MEMBERSCHOICE, MEMBERSMARKETINGDATABASE, 
        MEMBERSEARCH, OFS, RTMI, RTMIFX, SHOEBOXPOLICY, SOCIALSECURITYADMINISTRATION, TOOLBAR}
    
    public static String getDateString(Date dt){
        if(dt == null){return null;}
        return Datetime.newInstance(dt, Datetime.now().Time()).format('MM/dd/yyyy');
    }

}