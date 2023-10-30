/* defined using version 2.2.4 */
public class CMGPerson {

    public virtual class BirthDateInfoType {
        public string BirthDateType { get; set; }
        public Date BirthDate { get; set; }
        public string IncompleteBirthDate { get; set; }
    }
    
    public enum CompleteEmailAddressType_EmailType {
        HOME,
        WORK,
        PRIMARY,
        SECONDARY
    }
    
    public virtual class CompleteEmailAddressType { 
        public Integer EmailType { get; set; }
        public EmailAddressType EmailAddress { get; set; }
        public EmailStatusType EmailStatus { get; set; }        
        
        public void setEmailType(CompleteEmailAddressType_EmailType val) {
            if (val == CompleteEmailAddressType_EmailType.HOME)
                EmailType = 0;
            if (val == CompleteEmailAddressType_EmailType.WORK)
                EmailType = 1;
            if (val == CompleteEmailAddressType_EmailType.PRIMARY)
                EmailType = 2;
            if (val == CompleteEmailAddressType_EmailType.SECONDARY)
                EmailType = 3;
        }
    }
    
    public class EmailAddressType {
        public string Value {get;set;}
        
        public EmailAddressType() {}
        
        public EmailAddressType(String strEmail) {
            Value = strEmail;
        }
    }
    
    
    public virtual class CompletePersonNameType extends PersonNameType {
        public string FullName { get; set; }
        public string PreviousLastName { get; set; }
        public string NickName { get; set; }
        public string Initials { get; set; }
    }
    
    public class CompletePersonPPIDataType {
        public string GenderCode { get; set; }
        public BirthDateInfoType BirthDateInfo { get; set; }
        public string MaritalStatusCode { get; set; }
        public Date MaritalStatusDate { get; set; }
        public CMGAddress.CompleteAddressType HomeAddress { get; set; }
        public List<CompletePhoneType> CompletePhone { get; set; } // should this be a list? (Unbounded in the schema)
        public string TaxId { get; set; }
        public string TaxIdLastFour { get; set; }
        public string NonTaxIdentity { get; set; }
        public string NonTaxIdentityCode { get; set; } 
    }
    
    public class CompletePersonType extends PersonType {
        public CompletePersonPPIDataType CompletePersonPPIData { get; set; }
    }
    
    public class CompletePhoneType extends PhoneType {
        public string Extension { get; set; }
    }
    
    public virtual class PersonNameType {
        public String Prefix { get; set; }
        public String FirstName { get; set; }
        public String MiddleName { get; set; }
        public String LastName { get; set; }
        public String Suffix { get; set; }
        public String Designation { get; set; }
    }
    
    public virtual class PersonType extends CompletePersonNameType {
        public string PersonId { get; set; }
        public Date DeathDate { get; set; }
        public boolean DeceasedIndicator { get; set; }
        public List<CompleteEmailAddressType> CompleteEmailAddress { get; set; }
        public string PreferredMethodOfCorrespondence { get; set; }
        public List<CMGAddress.CompleteAddressType> OtherAddresses { get; set; }
    }
    
    public enum PhoneType_PhoneType {
        HOME,
        WORK,
        MOBILE,
        FAX
    }
    
    public virtual class PhoneType {
        public integer PhoneType { get; set; }
        public string PhoneNumber { get; set; }
        
        public void setPhoneType(PhoneType_PhoneType val) {  
            // Changed by Raghu for MDM Fix
       
            if (val == PhoneType_PhoneType.HOME)
                PhoneType = 1;
            if (val == PhoneType_PhoneType.WORK)
                PhoneType = 2;
            if (val == PhoneType_PhoneType.MOBILE)
                PhoneType = 3;
            if (val == PhoneType_PhoneType.FAX)
                PhoneType = 4;
                

             
        }
        
        //Defect  - 685702 Added as per latest Enum information, however, its going to impact Sales application as well.
        public PhoneType_PhoneType getPhoneType() {
            if (PhoneType == 1)
                return PhoneType_PhoneType.HOME;
            if (PhoneType == 2)
                return PhoneType_PhoneType.WORK;
            if (PhoneType == 3)
                return PhoneType_PhoneType.MOBILE;
            if (PhoneType == 4)
                return PhoneType_PhoneType.FAX;
            return null;
        }   
    }
    
    public virtual class SimplePersonType extends CompletePersonNameType {
        public string GenderCode { get; set; }
        public Date BirthDate { get; set; }
        public CMGAddress.CommonAddressType HomeAddress { get; set; }
        public PhoneType Phone { get; set; }
        public string EmailAddress { get; set; } 
        public string TaxId { get; set; }
        public string AccountNumber { get; set; }
    }
    
    public class EmailStatusType {
        public String Status { get; set; }
        public DateTime StatusDateTime { get; set; }
    }
    
}