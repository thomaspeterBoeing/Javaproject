/***
Copyright: Trustage
Purpose: Service for retieving marketing history for a member.
1.0 - Rick Baker   - 8/3/2023  - Created for new D2C Salesfore instance.
***/
public class ILHMarketingHistory implements IMarketingHistoryService {
    /***
     * Performs a search for contact marketing history by person Id.
     * @param personId -- The Id of the consumer Salesforce Person Account.
     * @return Returns a serialized JSON string that represents an array of ILHMarketingHistoryResultsWrapper class instances.
     */
    public List<ILHMarketingHistoryResultsWrapper> getMarketHistory(Map<String, Object> kvpSearchCriteria) {

        HttpResponse response;
        String personId = '';
        List<ILHMarketingHistoryResultsWrapper> searchResults = new List<ILHMarketingHistoryResultsWrapper>();

        try {
            personId = (String)kvpSearchCriteria.get('personId');

            if (String.isEmpty(personId)) {//No point in calling service if there's no person id
                return searchResults;
            }

            String[] parameterValues = new String[] {personId};
            //Getting response body
            response = HttpHelper.sendAPICRequest('MarketingHistory', parameterValues);

            if (String.isNotEmpty(response?.getBody())) {
                //Retrieving DataWeave script and getting the mapped data back
                DataWeave.Script script = new DataWeaveScriptResource.marketingHistoryScript();
                DataWeave.Result dwresult = script.execute(new Map<String, Object>{'payload' => response.getBody()});

                List<Object> results = (List<Object>)dwresult?.getValue();//Need to cast results to a list of object before casting to wrapper to check for null or empty result
                if (results != null && !results.isEmpty()) {
                    searchResults = ((List<ILHMarketingHistoryResultsWrapper>)results);
                    searchResults = ILHMarketingHistoryResultsWrapper.filterResults(searchResults);
                    searchResults = ILHMarketingHistoryResultsWrapper.findCreditUnions(searchResults);
                }
            }
        } catch (Exception ex) {
            new ErrorLogger(ex, 'The Marketing History Service is currently unavailable', 'MarketingHistorySearchService.cls', personId, 'Call Marketing History', 
                            null, 'MarketingHistory', response?.getStatusCode());
        }
        return searchResults;
    }
}