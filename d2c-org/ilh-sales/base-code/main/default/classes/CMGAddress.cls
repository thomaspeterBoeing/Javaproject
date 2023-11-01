/* address v23 */
public class CMGAddress {
    
    public class CommonAddressType {
        public List<String> AddressLines { get; set; }
        public String City { get; set; }
        public String StateProvince { get; set; }
        public String PostalCode { get; set; }
        public String Country { get; set; }
    }
    
    public class CompleteAddressType {
        public List<String> AddressType { get; set; }
        public String StreetAddressGroup { get; set; }
        public List<String> AddressLines { get; set; }
        public UspsDeliveryLinesType UspsDeliveryLines { get; set; }
        public String City { get; set; }
        public String StateProvinceCode { get; set; }
        public String StateProvince { get; set; }
        public String ZipCode { get; set; }
        public String Country { get; set; }
        public String PostalCode { get; set; }
        public String CountryCode { get; set; }
        public String County { get; set; }
        public String Region { get; set; }
        public String RegionCode { get; set; }
        public String Township { get; set; }
        public List<LegalAddressType> LegalAddress { get; set; }
        public Date StartDate { get; set; }
        public Date EndDate { get; set; }
        public Decimal YearsAtAddress { get; set; }
        public String RecurringStartMonthDay { get; set; } // XSD type is gMonthDay - http://www.w3.org/TR/xmlschema11-2/#gMonthDay
        public String RecurringEndMonthDay { get; set; } // XSD type is gMonthDay
        public String AddressDerivedKey { get; set; }
        public AddressStandardizationInfoType AddressStandardizationInfo { get; set; }       
    }
    
    public virtual class StandardizedAddressType {
        public AddressStandardizationInfoType AddressStandardizationInfo { get; set; }
        public List<String> AddressLines { get; set; }
        public String City { get; set; }
        public String StateProvince { get; set; }
        public String PostalCode { get; set; }
        public String Country { get; set; }
        public String AddressDerivedKey { get; set; }
        public CMGReusable.GeographicInfoType GeographicInfo { get; set; } // fixme
    }
    
    public class USMailingAddressType {
        public string StreetAddressGroup { get; set; }
        public List<String> AddressLines { get; set; }
        public UspsDeliveryLinesType UspsDeliveryLines { get; set; }
        public string City { get; set; }
        public string StateProvinceCode { get; set; }
        public string ZipCode { get; set; }
    }
    
    public class UspsDeliveryLinesType {
        public String OptionalInfo { get; set; }
        public String SupplementalDeliveryLine { get; set; }
        public String PrimaryDeliveryLine { get; set; }
    }
    
    public class LegalAddressType {
        public string LegalAddressCode { get; set; }
        public string Description { get; set; }
    }
    
    public class AddressStandardizationInfoType {
        public String AddressStandardizationType { get; set; }
        public String ConfidenceCode { get; set; }
    }
}