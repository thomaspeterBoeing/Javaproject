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

    /**
     * Purpose: Inner class that contains coverage option for eligible products
     */
    public class CoverageOption {
        public Integer coverage {get;set;}
        public Decimal premium {get;set;}
        public String frequency {get;set;}
    }

    /**
     * Purpose: Parses ConsumerEligibleQuoteResponse.QuoteResponse object into a list of EligibleProductQuoteResult
     * @param response : Response from ConsumerEligibleQuoteResponse.QuoteResponse object
     * @return List of EligibleProductQuoteResult
     */
    public static List<EligibleProductQuoteResult> parse(ConsumerEligibleQuoteResponse.QuoteResponse response) {
        List<EligibleProductQuoteResult> newResults = new List<EligibleProductQuoteResult>();
        List<ConsumerEligibleQuoteResponse.ProductQuotes> productQuotes = response.productQuotes;
        for (ConsumerEligibleQuoteResponse.ProductQuotes qr : productQuotes) {
            //Don't map record if it doesn't meet the criteria below
            if (qr?.insuranceProductDetails?.returnFlag != null && qr.insuranceProductDetails.returnFlag && qr?.coverageOptions != null && 
                !qr.coverageOptions.isEmpty() && qr?.productCode != null && qr?.insuranceProductDetails?.insuranceProductDisplayName != null &&
                qr?.insuranceProductDetails?.productCategory != null) {
                EligibleProductQuoteResult result = new EligibleProductQuoteResult();
                result.productCode = qr?.productCode;
                result.productName = qr?.insuranceProductDetails?.insuranceProductDisplayName;
                result.productCategory = qr?.insuranceProductDetails?.productCategory;
                result.coverages = new List<CoverageOption>();

                List<ConsumerEligibleQuoteResponse.CoverageOptions> cos = qr.coverageOptions;
                for (ConsumerEligibleQuoteResponse.CoverageOptions co : cos) {
                    //Don't map this coverage option if it doesn't meet the criteria below
                    if (co?.coverage != null && co?.frequency != null && co?.premium != null) {
                        CoverageOption newCo = new CoverageOption();
                        newCo.coverage = co.coverage;
                        newCo.frequency = co.frequency;
                        newCo.premium = co.premium;
                        result.coverages.add(newCo);
                    }
                }
                newResults.add(result);
            }
        }
        return newResults;
    }
}