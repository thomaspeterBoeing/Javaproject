public with sharing class ProductListRulesHelper {
    public ProductListRulesHelper() {

    }
    public static List<ProductQuoteResult> applyProductRules(List<ProductQuoteResult> pqrlst){
        List<ProductQuoteResult> updPqrlst = new List<ProductQuoteResult>();
        map<String, String> mapProductChars = new map<String, String>();
        map<String, String> mapProductName = new map<String, String>();
        for (Product2 p2 : [SELECT Id, Name, Underwriting_Type__c, ProductCode FROM Product2 WHERE IsActive=true]){
            if(p2.ProductCode.contains('ADD')){
               mapProductName.put(p2.productCode, p2.productCode);
           } else {
               mapProductName.put(p2.productcode, p2.Name);
           } //End
   
           mapProductChars.put(p2.productCode, p2.Underwriting_Type__c);
         }   
         for(ProductQuoteResult pqr:pqrlst){
            if (mapProductName.containsKey(pqr.insuranceProductCode)){
                pqr.prodCharecteristics=mapProductChars.get(pqr.insuranceProductCode);
                if(pqr.insuranceProductCode.contains('ADD Basic')){
                pqr.prodCharecteristics=pqr.prodCharecteristics+', $'+pqr.addinsuranceprodinfo.nonContributoryCoverageAmount;   
                }else if(pqr.insuranceProductCode.contains('ADD Single')){
                pqr.prodCharecteristics=pqr.prodCharecteristics+', $'+pqr.addinsuranceprodinfo.singleMonthlyRateAmount;
                if (pqr.addinsuranceprodinfo.eligibleRiderCoverage!=null && pqr.addinsuranceprodinfo.eligibleRiderCoverage.ridersAvailable)   {
                    pqr.prodCharecteristics=pqr.prodCharecteristics+'\r\n'+'+Yes Riders Available';
                }else{
                    pqr.prodCharecteristics=pqr.prodCharecteristics+'\r\n'+'-No Riders Not Available';
                }
    
                }else if(pqr.insuranceProductCode.contains('ADD Family')){
                pqr.prodCharecteristics=pqr.prodCharecteristics+', $'+pqr.addinsuranceprodinfo.familyMonthlyRateAmount;   
                if (pqr.addinsuranceprodinfo.eligibleRiderCoverage!=null && pqr.addinsuranceprodinfo.eligibleRiderCoverage.ridersAvailable)   {
                    pqr.prodCharecteristics=pqr.prodCharecteristics+'\r\n'+'+Yes Riders Available';
                }else{
                    pqr.prodCharecteristics=pqr.prodCharecteristics+'\r\n'+'-No Riders Not Available';
                }
                }
                system.debug('productcode---'+pqr.insuranceProductCode);
                pqr.insuranceProductCode=mapProductName.get(pqr.insuranceProductCode);
                
                updPqrlst.add(pqr);
            }
        }
         if(updPqrlst.isEmpty()){
            return null;
         }else{
            return updPqrlst;
         }

         

    }
}