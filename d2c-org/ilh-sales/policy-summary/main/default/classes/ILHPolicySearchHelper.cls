/**********************************************************************************
 * Title:  Policy Search Helper
 * Date:   Oct 2023
 * 
 * Description:  Apex Class to build reusable objects for Policy Search   
 * 
 * Details:      Create CPS Request. 
 *               Call CPS Search Service.
 *                
 *          
 * Modifications:
 *************************************************************************************/
public with sharing class ILHPolicySearchHelper {
    public static final Integer MAX_QUERY_RESULTS = 50; 
    
    public static PolicySearchRequest createPolicySearchRequest(String SearchCriteria,integer maxResultsToReturn) {
        PolicySearchRequest.SearchCriteria searchCriter = createSearchCriteria(SearchCriteria);

        PolicySearchRequest.SearchConsumerProfileType searchProfile = 
            new PolicySearchRequest.SearchConsumerProfileType(searchCriter);

            PolicySearchRequest.SearchRequestInfoType searchInfo = new PolicySearchRequest.SearchRequestInfoType();
            searchInfo.setElementsToReturn(
                new List<PolicySearchRequest.SearchRequestInfoType_enumElementsToReturn>{
                    PolicySearchRequest.SearchRequestInfoType_enumElementsToReturn.PRODUCTSUMMARY
                }
        );
        searchInfo.MaxResultsToReturn = maxResultsToReturn;    
        return new PolicySearchRequest(searchProfile, searchInfo);
    }


    public static PolicySearchRequest.SearchCriteria createSearchCriteria(String searchCriteria) {
        // Directly create a new SearchCriteria instance and set the necessary values
        PolicySearchRequest.SearchCriteria searchCriteriaObj = new PolicySearchRequest.SearchCriteria();
        searchCriteriaObj.personId = searchCriteria; 
    
        return searchCriteriaObj;
    }
    
  
    public static List<ILHPolicyResultsWrapper> searchCPS(PolicySearchRequest cpsRequest) {
        //No request sent to method, so return null
        if (cpsRequest == null || String.isBlank(cpsRequest.SearchConsumerProfile.personId)) {
            new ErrorLogger(null, 'PersonID is not available on this record to proceed with Policy Summary search', 'ILHPolicySearchHelper.cls', null, 'searchCPS', null, 
                            'Validation_BeforeCPS_Search', null);
            return new List<ILHPolicyResultsWrapper>();
        }
        List<ILHPolicyResultsWrapper> ilhSearchResults = new List<ILHPolicyResultsWrapper>();
        
        //Create request payload
        String requestPayload = JSON.serialize(cpsRequest, true);
        System.debug('what is in the request payload' +requestPayload);
        HttpResponse response;

        try {
            //Call CPS search service
            response = HttpHelper.sendAPICRequest('CPS_Search',requestPayload);
            System.debug('Response from service' +response);
            PolicySearchResponse cpsResponse = PolicySearchResponse.parse(response?.getBody()); 
            System.debug('Response from service body' +cpsResponse);
  
       
            if (cpsResponse.ConsumerProfileList != null) {
                 for (CMGCommon.ConsumerProfileType consumerProfile : cpsResponse?.ConsumerProfileList) {
                    for (CMGProductSummary.ConsumerProductSummaryType productSummary : consumerProfile?.ConsumerProductSummaryList) {
                            ilhSearchResults.add(new ILHPolicyResultsWrapper(productSummary));
                    }
                }
                
               
            }
        system.debug('post processing response' +ilhSearchResults);
      
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while searching CPS.', 'ILHPolicySearchHelper.cls', null, 'CPS Search', requestPayload, 
                            'CPS_Search', response?.getStatusCode());
        }
        return ilhSearchResults;
    }  

    
}