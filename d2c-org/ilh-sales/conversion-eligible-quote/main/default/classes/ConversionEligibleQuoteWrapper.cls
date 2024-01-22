/**********************************************************************************
 * Title:  ConversionEligibleQuoteWrapper
 * Date:   Jan 2024
 * 
 * Description:  Wrapper class for the ConversionEligibleQuote endpoint  
 * 
 *************************************************************************************/
public class ConversionEligibleQuoteWrapper {
    public List<QuoteGridRow> quoteGrid;

    public ConversionEligibleQuoteWrapper(List<QuoteGridRow> quoteGrid) {
    this.quoteGrid = quoteGrid;
    }

    public class QuoteGridRow {
        public Integer coverageAmount;
        public Decimal annualPremiumAmount;
        public Decimal semiAnnualPremiumAmount;
        public Decimal quarterlyPremiumAmount;
        public Decimal monthlyPremiumAmount;
    }

    public static List<QuoteGridRow> parseFromJSON(String jsonResponse) {
        List<QuoteGridRow> quoteGridRows = new List<QuoteGridRow>();

        try {
            ConversionEligibleQuoteResponse response = ConversionEligibleQuoteResponse.parse(jsonResponse);

            if (response != null && response.conversionEligibilityDetails != null &&
                response.conversionEligibilityDetails.fullConversion != null &&
                response.conversionEligibilityDetails.fullConversion.quotes != null &&
                response.conversionEligibilityDetails.fullConversion.quotes.primaryConversionDateQuotes != null) {

                // Iterate through primaryConversionDateQuotes
                for (ConversionEligibleQuoteResponse.ConversionDateQuotes quote : response.conversionEligibilityDetails.fullConversion.quotes.primaryConversionDateQuotes) {
                    QuoteGridRow row = new QuoteGridRow();
                    row.coverageAmount = Integer.valueOf(quote.coverageAmount);
                    row.annualPremiumAmount = Decimal.valueOf(quote.annualPremiumAmount);
                    row.semiAnnualPremiumAmount = Decimal.valueOf(quote.semiAnnualPremiumAmount);
                    row.quarterlyPremiumAmount = Decimal.valueOf(quote.quarterlyPremiumAmount);
                    row.monthlyPremiumAmount = Decimal.valueOf(quote.monthlyPremiumAmount);

                    quoteGridRows.add(row);
                    System.debug('row added ->' + row);
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing JSON: ' + e.getMessage());
        }

        return quoteGridRows;
    }
}
