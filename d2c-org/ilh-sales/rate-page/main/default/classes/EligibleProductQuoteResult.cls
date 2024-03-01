/***
Copyright: TruStage
Purpose: This class contains results for eligible product quotes
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public class EligibleProductQuoteResult {
    public String productCode {get;set;}
    public List<CoverageOption> coverages {get;set;}
    public List<BillingOption> billingOptions {get;set;}

    /**
     * Purpose: Inner class that contains coverage option for eligible products
     */
    public class CoverageOption {
        public Integer coverage {get;set;}
        public Decimal annual {get;set;}
        public Decimal monthly {get;set;}
        public Decimal quarterly {get;set;}
        public Decimal semiannual {get;set;}
    }

    public class BillingOption {
        public String billingMethod {get;set;}
        public String effectiveDate {get;set;}
    }

    /**
     * Purpose: Parses ConversionEligibleQuoteWrapper into list of EligibleProductQuoteResult
     * @param response : Response from conversion service
     * @param isTermBeingKept: Indicates if we should get full or partial conversion quotes
     * @return List of EligibleProductQuoteResult
     */
    public static List<EligibleProductQuoteResult> parse(ConversionEligibleQuoteWrapper response, Boolean isTermBeingKept) {
        List<EligibleProductQuoteResult> results = new List<EligibleProductQuoteResult>();
        ConversionEligibleQuoteWrapper.Conversion fullConversion = response.conversionEligibilityDetails.fullConversion;
        ConversionEligibleQuoteWrapper.Conversion partialConversion = response.conversionEligibilityDetails.partialConversion;
        ConversionEligibleQuoteWrapper.Conversion conversionObj = !isTermBeingKept ? fullConversion : partialConversion;

        if(conversionObj.quotes.primaryConversionDateQuotes != null && conversionObj.quotes.primaryConversionDateQuotes.size() > 0) {
            EligibleProductQuoteResult result = new EligibleProductQuoteResult();
            result.productCode = response.conversionEligibilityDetails.productCode;
            result.coverages = new List<CoverageOption>();

            // Iterate through primaryConversionDateQuotes
            for (ConversionEligibleQuoteWrapper.ConversionDateQuotes rate : conversionObj.quotes.primaryConversionDateQuotes) {
                result.coverages.add(parseCoverageOption(rate));
            }
            results.add(result);
        }
        return results;
    }

    /**
     * Purpose: Parses ConversionEligibleQuoteWrapper.ConversionDateQuotes into CoverageOption
     * @param rate : Rate from conversion service
     * @return CoverageOption object
     */
    @TestVisible
    private static CoverageOption parseCoverageOption(ConversionEligibleQuoteWrapper.ConversionDateQuotes rate) {
        CoverageOption co = new CoverageOption();
        if (String.isNotEmpty(rate?.coverageAmount)) {
            co.coverage = Integer.valueOf(rate?.coverageAmount);
        }
        if (String.isNotEmpty(rate?.annualPremiumAmount)) {
            co.annual = Decimal.valueOf(rate?.annualPremiumAmount);
        }
        if (String.isNotEmpty(rate?.semiAnnualPremiumAmount)) {
            co.semiannual = Decimal.valueOf(rate?.semiAnnualPremiumAmount); 
        }
        if (String.isNotEmpty(rate?.quarterlyPremiumAmount)) {
            co.quarterly = Decimal.valueOf(rate?.quarterlyPremiumAmount);  
        }
        if (String.isNotEmpty(rate?.monthlyPremiumAmount)) {
            co.monthly = Decimal.valueOf(rate?.monthlyPremiumAmount); 
        }
        return co;
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
                
                EligibleProductQuoteResult result = new EligibleProductQuoteResult();
                result.productCode = qr?.productCode;
                result.coverages = parseCoverageOptions(qr.coverageOptions);

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
    @TestVisible
    private static Boolean shouldParseResult(ConsumerEligibleQuoteResponse.ProductQuotes quoteResult, String selectedProductCategory) {
        return (quoteResult?.insuranceProductDetails?.returnFlag != null && quoteResult.insuranceProductDetails.returnFlag && 
        quoteResult?.coverageOptions != null && !quoteResult.coverageOptions.isEmpty() && quoteResult?.productCode != null && 
        quoteResult?.insuranceProductDetails?.insuranceProductDisplayName != null && quoteResult?.insuranceProductDetails?.productCategory != null && 
        getProductCategory(quoteResult?.insuranceProductDetails?.productCategory).equalsIgnoreCase(selectedProductCategory));
    }

    /**
     * Purpose: Parses product quote coverage options into Result coverage options
     * @param cos : Coverage options from product quote response
     * @return List of coverage options
     */
    @TestVisible
    private static List<CoverageOption> parseCoverageOptions(List<ConsumerEligibleQuoteResponse.CoverageOptions> cos) {
        List<CoverageOption> coverages = new List<CoverageOption>();
        Map<Integer, CoverageOption> coMap = new Map<Integer, CoverageOption>();
        for (ConsumerEligibleQuoteResponse.CoverageOptions co : cos) {
            //Don't map this coverage option if it doesn't meet the criteria below
            if (co?.coverage != null && co?.frequency != null && co?.premium != null) {
                CoverageOption newCo = coMap.get(co.coverage);
                if (newCo == null) {
                    newCo = new CoverageOption();
                }
                if (co.frequency == 'Annual') {
                    newCo.annual = co.premium;
                } else if (co.frequency == 'Monthly') {
                    newCo.monthly = co.premium;
                } else if (co.frequency == 'Quarterly') {
                    newCo.quarterly = co.premium;
                } else if (co.frequency == 'Semiannual') {
                    newCo.semiannual = co.premium;
                }
                newCo.coverage = co.coverage;
                coMap.put(co.coverage, newCo);
            }
        }
        coverages.addAll(coMap.values());
        return coverages;
    }

    /**
     * Purpose: Parses product quote billing options into Result billing options
     * @param billingOptions : Billing options from product quote response
     * @return List of billing options
     */
    @TestVisible
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
    @TestVisible
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