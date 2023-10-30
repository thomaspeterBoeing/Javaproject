public class CMGProductSummary {
    
    public class ConsumerProductSummaryType extends ProductSummaryType {
        public CMGReusable.OrganizationType Organization { get; set; }
    }
    
    public virtual class ProductSummaryType extends SimpleProductSummaryType {
        public string SourceSystemProductKey { get; set; }
        public string Status { get; set; }
        public string CommonStatus { get; set; }
        public Date EffectiveDate { get; set; }
        public Date TerminationDate { get; set; }
        public CoverageInformationType CoverageInformation { get; set; }
    }
    
    public virtual class SimpleProductSummaryType {
        public string SourceSystemId { get; set; }
        public string ProductNumber { get; set; }
        public integer ProductRelationship { get; set; }
    }
    
    public class CoverageInformationType {
        public string CoverageType { get; set; }
        public integer CoverageAmount { get; set; }
    }
}