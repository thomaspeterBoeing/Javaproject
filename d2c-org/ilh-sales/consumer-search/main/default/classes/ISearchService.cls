/**********************************************************************************
 * Title:  Search Service Inrerface
 * Date:   Sept 2023
 * 
 * Description:  This is the interface for search service.  
 *  
 * Details    :  The interface definition that all concrete search service classes will implement         
 * Modifications:
 *************************************************************************************/

/***
Copyright: CUNA Mutual Group
Purpose: The interface definition that all concrete search service classes will implement.
1.0 - Rick Baker   - 822/2023  - Created for new D2C Salesfore instance.
***/
public interface ISearchService {

    /***
     * The entry point into the dependency injection framework search services.
     *
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     *
     * @return Returns an instance list of ILHConsumerResultsWrapper contain classes
     */
    List<ILHConsumerResultsWrapper> search (Map<String, Object> kvpSearchCriteria);
}