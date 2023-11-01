/**********************************************************************************
 * Title:  Search Service
 * Date:   Sept 2023
 * 
 * Description:  This is service layer of the dependency injection search services.
 *               This is where each concrete search service class will be dispatched.
 *  
 *          
 * Modifications:
 *************************************************************************************/
/**
 * Copyright: CUNA Mutual Group
 * @Author: Adam
 * @Create Time: 2023-09-12 12:49:32
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-12 18:21:22
 */
public without sharing class ILHSearchService {

      

    public ILHSearchService() {}

    /***
     * The entry point into the dependency injection framework search services.
     *
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     *
     * @return Returns a list of diISearchService instances from various search services.
     */
    public List<ILHConsumerResultsWrapper> runSearch(Map<String, Object> kvpSearchCriteria) {
        return  dispatchSearchServices(kvpSearchCriteria);
    }

    /***
     * This method handles the logic for dispatching search services.
     *
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     *
     * @return Returns a list of diISearchService instances from various search services.
     */
    private List<ILHConsumerResultsWrapper> dispatchSearchServices(Map<String, Object> kvpSearchCriteria) {
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();

        //Get all search class instances
        List<ISearchService> classInstances = ILHSearchFactory.getInstances();

        for(ISearchService classInstance : classInstances) {
            //Call the search method from the current class instance, and add it to the list of search results
            searchResults.addAll(((ISearchService)classInstance).search(kvpSearchCriteria));
        }        
        return (new ILHSearchMergeImpl()).mergeResults(searchResults);           
    }
}