/***
Copyright: CUNA Mutual Group
Purpose: To interact with the AD&D Basic web service.
2.0 - Balaji N - 05/02/2018 - Added BeneficiaryList as part of PBI 889809 due to BizTalk changes.
***/
public class CMGADnDBasic{
    public class ApplicationInformation {
        public String ContractNumber                                            {get; set;}
        public String ProductIdentifier                                         {get; set;}
        public String BasicAmount                                               {get; set;}
        public String EmailAddress                                              {get; set;}
        public String MarketingSequenceNumber                                   {get; set;}
        public String AgentID                                                   {get; set;}
        public DateTime SignedDateTime                                          {get; set;}
        
        public  ADnDEnum_ProductIdentifier getProductIdentifierEnum(){
            if(this.ProductIdentifier == null){return null;}
            for(ADnDEnum_ProductIdentifier item : ADnDEnum_ProductIdentifier.values()){
                if(string.valueOf(item.ordinal()) == this.ProductIdentifier){
                    return item;
                }
            }
            return null;
        }
        public void setProductIdentifierEnum(ADnDEnum_ProductIdentifier value){
            this.ProductIdentifier = String.valueOf(value.ordinal());
        }
        public String getProductIdentifierStr(){
            return this.ProductIdentifier;
        }
        public void setProductIdentifierStr(String value){
            value = (value.contains('2012')) ? 'ADD2012' : 'ADD2001';
            
            for(ADnDEnum_ProductIdentifier item : ADnDEnum_ProductIdentifier.values()){
                if(item.name() == value){
                    this.ProductIdentifier = String.valueOf(item.ordinal());
                    break;
                }
            }
        }
        
        public String getSignedDateTimeStr()
        {
            if(this.SignedDateTime == null){return null;}
            return this.SignedDateTime.format('MM/dd/yyyy hh:mm a');
        }
        public void setSignedDateTimeStr(String value)
        {
            if(value != null && value != ''){
                this.SignedDateTime = DateTime.parse(value);
            }
        }
    }           // BNA - End of ApplicationInformation Class
    
    public class InsuredInformation{
        public String FirstName                                                 {get; set;}
        public String MiddleName                                                {get; set;}
        public String LastName                                                  {get; set;}
        public String AddressLine1                                              {get; set;}
        public String AddressLine2                                              {get; set;}
        public String AddressLine3                                              {get; set;}
        public String City                                                      {get; set;}
        public String StateProvinceCode                                         {get; set;}
        public String Zipcode                                                   {get; set;}
        public String PhoneNumber                                               {get; set;}
        public Date BirthDate                                                   {get; set;}

        public String getBirthDateStr()
        {
            if(this.BirthDate == null){return null;}
            return getDateString(this.BirthDate);
        }
        public void setBirthDateStr(String value)
        {
            if(value != null && value != '')
            {
                this.BirthDate = Date.parse(value);
            }
        }
    }           // BNA - End of InsuredInformation

    //2.0 - New Class added. CIS Team migrated their old AD&D Basic Enrollment service from 2008 servers into the latest servers
    //and BizTalk was also brought into the mix. BizTalk needs the AD&D Enrollment Request in the new format by adding the 
    //BeneficiaryList tag in the request. Sample Request is below.
/**
 * 
 * The corresponding Apex Class for the above request was generated using https://json2apex.herokuapp.com.
 * 
 **/    
    public class BeneficiaryList {
        public List<Beneficiary> Beneficiary;
        
        public BeneficiaryList() {}
        
        public BeneficiaryList(List<Beneficiary> benef) {
            this.Beneficiary = benef;
        }
    }           // BNA - End of BeneficiaryList Class

    public class Beneficiary {
        public String Relationship;
        public String PrimaryIndicator;
        public Object Percentage;
        public String FullName;

        public Beneficiary(){}
        
        public Beneficiary(String FullName, String PrimaryIndicator, Integer Percentage, String Relationship){
            this.FullName = FullName;
            this.setPrimaryIndicatorStr(PrimaryIndicator);
            this.Percentage = Percentage;
            this.setRelationshipStr(Relationship);
        }

        public void setPrimaryIndicatorStr(String value)
        {
            value = ((value == 'Yes') ? 'Primary' : ((value == 'No') ? 'Contingent' : value));
            
            for(ADnDEnum_PrimaryIndicatorCode item : ADnDEnum_PrimaryIndicatorCode.values()){
                if(item.name() == value){
                    this.PrimaryIndicator = item.name();
                    break;
                }
            }
        }
        
        public void setRelationshipStr(String value){
            this.Relationship = value;//2.0 BizTalk needs the actual relationship string, not the enum Integer.
        }
    }           //BNA - End of Beneficiary Class
    
    public Enum ADnDEnum_ProductIdentifier {ADD2001, ADD2012}
    public Enum ADnDEnum_PrimaryIndicatorCode {Primary, Contingent}
    public Enum ADnDEnum_RelationShipCode {Aunt, BrotherInLaw, Brother, Child, Cousin, Daughter, DaughterInLaw, Estate, Father, FatherInLaw, Friend, Grandfather, Grandmother, Granddaughter, Grandson, Husband, MotherInLaw, Mother, Nephew, Niece, Parent, Stepdaughter, SonInLaw, Sister, Son, Spouse, SisterInLaw, Stepson, Stepfather, Stepmother, Uncle, Wife}
    
    public static String getDateString(Date dt){
        if(dt == null){return null;}
        return Datetime.newInstance(dt, Datetime.now().Time()).format('yyyy-MM-dd');
    }
 
}