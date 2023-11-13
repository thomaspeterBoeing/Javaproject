 /**********************************************************************************
 * Title:  Policy Summary Controller
 * Date:   Oct 2023
 * 
 * Description:  Apex Class to that is used in policySumSearch LWC   
 * 
 *                
 *          
 * Modifications:
 *************************************************************************************/
public with sharing class PolicySummaryController {
    @AuraEnabled
    public static List<ILHPolicyResultsWrapper> search(String SearchCriteria) {       
        system.debug('SearchCriteria passed from LWC'+SearchCriteria);
        return (new ILHPolicySearchService()).runSearch(SearchCriteria);    
    }
    
}