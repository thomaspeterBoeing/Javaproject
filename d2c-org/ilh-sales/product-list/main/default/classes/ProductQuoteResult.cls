/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-24 22:27:55
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-29 01:21:14
 * @Description:
 */

 public class ProductQuoteResult {
    
    public ProductQuoteResult(ConsumerEligibleQuoteResponse.ProductQuotes prodQuote){        
        this.insuranceProductCode = prodQuote.productCode;
        if (prodQuote.insuranceProductDetails!=null){
            this.isEndorsed=prodQuote.insuranceProductDetails.isEndorsed;
            if(prodQuote.insuranceProductDetails.endorsementList!=null && !prodQuote.insuranceProductDetails.endorsementList.isEmpty())
                this.endorsementList=prodQuote.insuranceProductDetails.endorsementList[0];
            
            this.lifeInsuranceProductInfo=prodQuote.insuranceProductDetails.lifeInsuranceProductInfo;
            this.addinsuranceprodinfo=prodQuote.insuranceProductDetails.aDnDInsuranceProductInfo;
            this.quotable=prodQuote.insuranceProductDetails.quotable;
        }
        this.coverageoptions=prodQuote.coverageOptions;
        this.frequency=prodQuote.frequency;
        this.billMethod=prodQuote.billingMethod;
    }
    
    @AuraEnabled    
    public string insuranceProductCode;
    @AuraEnabled    
    public list<ConsumerEligibleQuoteResponse.CoverageOptions> coverageoptions;
    
    @AuraEnabled
    public List<String> frequency;			
    @AuraEnabled
    public List<String> billMethod;
    @AuraEnabled
    public String insuranceProductDescription;
    
    @AuraEnabled
    public String productType;	

    @AuraEnabled    
    public String quotable;
    
    @AuraEnabled			
    public String systemProductCode;
    @AuraEnabled
    public String issueStateCode;			
    @AuraEnabled
    public String prodCharecteristics;			
    
    @AuraEnabled
    public ConsumerEligibleQuoteResponse.LifeInsuranceProductInfo lifeInsuranceProductInfo;			
    
    @AuraEnabled
    public ConsumerEligibleQuoteResponse.ADnDInsuranceProductInfo addinsuranceprodinfo ;
   
    
    @AuraEnabled
    public Boolean isEndorsed;			
    
    @AuraEnabled   
    public String endorsementList;	

    @AuraEnabled
    public string insuranceProductDisplayName;
}