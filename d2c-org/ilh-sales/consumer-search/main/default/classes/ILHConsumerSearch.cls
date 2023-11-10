/**
 * Copyright: TruStage
 * Purpose: This class performs a search for CPS contacts
 */
public class ILHConsumerSearch implements ISearchService {
    /**
     * Purpose: This method searches CPS for contacts
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return -- Returns a List of search results from CPS
     */
    public List<ILHConsumerResultsWrapper> search(Map<String, Object> kvpSearchCriteria) {
        List<ILHConsumerResultsWrapper> results = new List<ILHConsumerResultsWrapper>();
        
        //Call CPS for contacts based on the search criteria passed into this method
        ConsumerProfileServiceRequest searchRequest = ILHSearchHelper.createCPSSearchRequest(kvpSearchCriteria, 10);
        results.add(ILHSearchHelper.searchCPS(searchRequest));

        //Search SF for records.  Add to final list if there's 
        results.add(ILHSearchHelper.searchSF(kvpSearchCriteria, results));
        return results;
    }
}