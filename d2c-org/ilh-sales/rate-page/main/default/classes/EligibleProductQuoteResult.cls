/***
Copyright: TruStage
Purpose: This class contains results for eligible product quotes
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public class EligibleProductQuoteResult {
    public String productCode {get;set;}
    public String productName {get;set;}
    public String productCategory {get;set;}
    public List<CoverageOption> coverages {get;set;}
    public List<BillingOption> billingOptions {get;set;}

    /**
     * Purpose: Inner class that contains coverage option for eligible products
     */
    public class CoverageOption {
        public Integer coverage {get;set;}
        public Decimal premium {get;set;}
        public String frequency {get;set;}
        public Boolean ridersAvailable {get;set;}
    }

    public class BillingOption {
        public String billingMethod {get;set;}
        public String effectiveDate {get;set;}
    }

    /**
     * Purpose: Parses ConsumerEligibleQuoteResponse.QuoteResponse object into a list of EligibleProductQuoteResult
     * @param response : Response from ConsumerEligibleQuoteResponse.QuoteResponse object
     * @return List of EligibleProductQuoteResult
     */
    public static List<EligibleProductQuoteResult> parse(ConsumerEligibleQuoteResponse.QuoteResponse response, String selectedProductCategory) {
        List<EligibleProductQuoteResult> newResults = new List<EligibleProductQuoteResult>();
        List<ConsumerEligibleQuoteResponse.ProductQuotes> productQuotes = response?.productQuotes;
        for (ConsumerEligibleQuoteResponse.ProductQuotes qr : productQuotes) {
            //Don't map record if it doesn't meet the criteria below
            if (shouldParseResult(qr, selectedProductCategory)) {
                ConsumerEligibleQuoteResponse.ADnDInsuranceProductInfo addProductInfo  = qr?.insuranceProductDetails?.aDnDInsuranceProductInfo;
                ConsumerEligibleQuoteResponse.LifeInsuranceProductInfo lifeProductInfo = qr?.insuranceProductDetails?.lifeInsuranceProductInfo;
                List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList> addBillingOptions = addProductInfo?.eligibleBillingOptionsList;
                List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList> lifeBillingOptions = lifeProductInfo?.eligibleBillingOptionsList;
                Boolean ridersAvailable = addProductInfo?.eligibleRiderCoverage?.ridersAvailable;
                
                EligibleProductQuoteResult result = parseResultInfo(qr);
                result.coverages = parseCoverageOptions(qr.coverageOptions, addProductInfo?.eligibleRiderCoverage?.ridersAvailable);

                if (addBillingOptions != null) {
                    result.billingOptions = parseBillingOptions(addBillingOptions);//If ADD product, then pass ADD billing options
                } else if (lifeBillingOptions != null) {
                    result.billingOptions = parseBillingOptions(lifeBillingOptions);//If Life product, then pass life billing options
                }
                newResults.add(result);
            }
        }
        return newResults;
    }

    /**
     * Purpose: Determines if a result should be updated
     * @param quoteResult Quote result that will determine if we parse
     * @param selectedProductCategory Product category that will determine if we parse
     * @return If true, then we will parse result.  If false, then we skip this result
     */
    private static Boolean shouldParseResult(ConsumerEligibleQuoteResponse.ProductQuotes quoteResult, String selectedProductCategory) {
        return (quoteResult?.insuranceProductDetails?.returnFlag != null && quoteResult.insuranceProductDetails.returnFlag && 
        quoteResult?.coverageOptions != null && !quoteResult.coverageOptions.isEmpty() && quoteResult?.productCode != null && 
        quoteResult?.insuranceProductDetails?.insuranceProductDisplayName != null && quoteResult?.insuranceProductDetails?.productCategory != null && 
        getProductCategory(quoteResult?.insuranceProductDetails?.productCategory).equalsIgnoreCase(selectedProductCategory));
    }

    /**
     * Purpose: Parses product quote response into EligibleProductQuoteResult object
     * @param productQuoteResult : Result from product quote response
     * @return Instance of EligibleProductQuoteResult
     */
    private static EligibleProductQuoteResult parseResultInfo(ConsumerEligibleQuoteResponse.ProductQuotes productQuoteResult) {
        EligibleProductQuoteResult result = new EligibleProductQuoteResult();
        result.productCode = productQuoteResult?.productCode;
        result.productName = productQuoteResult?.insuranceProductDetails?.insuranceProductDisplayName;
        return result;
    }

    /**
     * Purpose: Parses product quote coverage options into Result coverage options
     * @param cos : Coverage options from product quote response
     * @return List of coverage options
     */
    private static List<CoverageOption> parseCoverageOptions(List<ConsumerEligibleQuoteResponse.CoverageOptions> cos, Boolean ridersAvailable) {
        List<CoverageOption> coverages = new List<CoverageOption>();
        for (ConsumerEligibleQuoteResponse.CoverageOptions co : cos) {
            //Don't map this coverage option if it doesn't meet the criteria below
            if (co?.coverage != null && co?.frequency != null && co?.premium != null) {
                CoverageOption newCo = new CoverageOption();
                newCo.ridersAvailable = ridersAvailable;
                newCo.coverage = co.coverage;
                newCo.frequency = co.frequency;
                newCo.premium = co.premium;
                coverages.add(newCo);
            }
        }
        return coverages;
    }

    /**
     * Purpose: Parses product quote billing options into Result billing options
     * @param billingOptions : Billing options from product quote response
     * @return List of billing options
     */
    private static List<BillingOption> parseBillingOptions(List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList> billingOptions) {
        List<BillingOption> resultBillingOptions = new List<BillingOption>();
        for (ConsumerEligibleQuoteResponse.EligibleBillingOptionsList bo : billingOptions) {
            BillingOption billingOption = new BillingOption();
            billingOption.billingMethod = bo?.billingMethodCode;
            billingOption.effectiveDate = bo?.effectiveDate;
            resultBillingOptions.add(billingOption);             
        }
        return resultBillingOptions;
    }

    /**
     * Purpose: Determines a new product category based on the product category given
     * @param productCategory Product category that will determine a new product category
     * @return A new product category
     */
    private static String getProductCategory(String productCategory) {
        String newProductCategory = '';

        if (String.isNotEmpty(productCategory)) {
            if (productCategory.equalsIgnoreCase('ADD') || productCategory.equalsIgnoreCase('Conversion')) {
                newProductCategory = productCategory;
            } else {
                newProductCategory = 'Life';
            }
        }
        return newProductCategory;
    }
}