public class MockProductQuoteService implements IProductQuoteService {
    public ConsumerEligibleQuoteResponse.QuoteResponse getQuoteResponse(Map<String, Object> rateRequest){
        System.HttpResponse response;
        String reqString = JSON.serialize(rateRequest, true);     
        try {   
            system.debug('reqqq--'+reqString);
            response = HTTPHelper.sendAPICRequest('ConsQligibleQuote', reqString);
            
            ConsumerEligibleQuoteResponse.QuoteResponse results = ConsumerEligibleQuoteResponse.parse(response.getBody());
          
            return results;
        } catch(Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting eligible quotes.', 'QuoteProductService.cls', null, 'Get Eligible Quotes', 
                            reqString, 'ConsQligibleQuote', response?.getStatusCode());     
        }
        return null;

    }
}