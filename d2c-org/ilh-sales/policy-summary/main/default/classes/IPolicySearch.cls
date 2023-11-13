/**********************************************************************************
 * Title:  Policy Search Service Interface
 * Date:   Oct 2023
 * 
 * Description:  This is the interface for Policy search service.  
 *  
 * Details    :  The interface definition that all concrete search service classes will implement         
 * Modifications:
 *************************************************************************************/

public interface IPolicySearch {

    /***
     * The entry point into the dependency injection framework search services.
     *
     * @param SearchCriteria -- The search criteria in the format of a string
     *
     * @return Returns an instance list of ILHPolicyResultsWrapper contain classes
     */
    List<ILHPolicyResultsWrapper> search (String SearchCriteria);
}