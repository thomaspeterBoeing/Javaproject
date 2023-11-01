/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-12 12:49:32
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-12 18:18:37
 * @Description:This class performs a search for CPS contacts
 */
public class ILHConsumerSearch implements ISearchService {
    
    /**
     * This method searches CPS for contacts
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return -- Returns a List of search results from CPS
     */
    public List<ILHConsumerResultsWrapper> search(Map<String, Object> kvpSearchCriteria) {
        
        List<ILHConsumerResultsWrapper> results = new List<ILHConsumerResultsWrapper>();
        List<ILHConsumerResultsWrapper> sfResults = new List<ILHConsumerResultsWrapper>();
        
        //Call CPS for contacts based on the search criteria passed into this method
        ConsumerProfileServiceRequest searchRequest = ILHSearchHelper.createCPSSearchRequest(kvpSearchCriteria, 10);
        results = ILHSearchHelper.searchCPS(searchRequest);

        //Search SF for records.  Add to final list if there's 
        sfResults = ILHSearchHelper.searchSF(kvpSearchCriteria, results);
        if (sfResults != null && !sfResults.isEmpty()) {
            results.addAll(sfResults);
        }
        return results;
    }
}