/* CMG Reusable Components 1.0 */
public class CMGReusable {
    public class GeographicInfoType {
        public string Latitude { get; set; }
        public string Longitute { get; set; }
    }
    
    public virtual class ChangedAttributeType {
        public CreationInfoType CreationInfo { get; set; }
        public ValidationInfoType ValidationInfo { get; set; } 
    }
    
    public class CreationInfoType {
        public DateTime CreationDateTime { get; set; }
        public String SourceSystemId { get; set; }
        public String SourceSystemKey { get; set; }
        public OrganizationType Organization { get; set; }
    }
    
    public class EffectiveChangedAttributeType extends ChangedAttributeType {
        public DateTime EffectiveDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
    }
    
    public class OrganizationType {
        public String ContractNumber { get; set; }
        public String OrganizationId { get; set; }
        public String OrganizationSegment { get; set; }
        public String CreditUnion {get;set;}
    }
    
    public class ValidationInfoType {
        public DateTime ValidationDateTime { get; set; }
        public String UserId { get; set; }
    }
}