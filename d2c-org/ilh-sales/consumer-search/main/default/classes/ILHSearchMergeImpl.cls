/**********************************************************************************
 * Title:  SearchResults Merge
 * Date:   Sept 2023
 * 
 * Description:  This class will combine cps search results with Salesforce. The merging logic is:  
 *  
 * Details    :  Remove duplicate rows
                 Match on Person ID
                 Match on Person Account ID    
                 Match on FN, LN, DOB
                 From match, always take CPS info:  FN, MN, LN, Suffix, Person ID, SSN, DOB, Address, Gender, Home phone, Cell phone, work phone, deceased, plus SF Person Account Id
                 If no CPS match for a SF records, include that record in the search results with SF data for the same fields
                 Use the deduped list for search results           
 * Modifications:
 *************************************************************************************/

public with sharing class ILHSearchMergeImpl {    
    /**
    ***************************************************************************************************************************************
    @Method Name    : mergeResults
    @author         : Adam Perschke-Ely
    @param searchResults  : List of all results
    @return : List of merged results
    @description    : This method determines if a row is from cps or sf, and then adds the row to the correct list
    ***************************************************************************************************************************************
    */
    public List<ILHConsumerResultsWrapper> mergeResults(List<ILHConsumerResultsWrapper> searchResults){
        List<ILHConsumerResultsWrapper> sfResults = new List<ILHConsumerResultsWrapper>();//Set that contains results from Salesforce
        List<ILHConsumerResultsWrapper> cpsResults = new List<ILHConsumerResultsWrapper>();//List that contains merged resutlts from SF and CPS   
        
        for (ILHConsumerResultsWrapper sr: searchResults) {//Looping through all search results
            if (sr.mySource == ILHConsumerResultsWrapper.Source.CPS) {//Search result is from CPS
                cpsResults.add(sr);
            } else if (sr.mySource == ILHConsumerResultsWrapper.Source.SALESFORCE) {//Search result is from Salesforce
                sfResults.add(sr);
            }
        }
        return mergeResultset(sfResults, cpsResults);
    }

    /**
    ***************************************************************************************************************************************
    @Method Name    : mergeResultset
    @author         : Adam Perschke-Ely
    @param lstSFMatches  : List of sf results
    @param lstCPSMatches  : List of cps results
    @return : List of merged results
    @description    : This method merges sf results with cps results
    ***************************************************************************************************************************************
    */
    private List<ILHConsumerResultsWrapper> mergeResultset(List<ILHConsumerResultsWrapper> lstSFMatches, List<ILHConsumerResultsWrapper> lstCPSMatches) {
                                                                
        List<ILHConsumerResultsWrapper> lstMergeset = new List<ILHConsumerResultsWrapper>();
        Map<Integer,ILHConsumerResultsWrapper> mapSFContacts = new Map<Integer,ILHConsumerResultsWrapper>();
        Map<Integer,ILHConsumerResultsWrapper> mapCPSContacts = new Map<Integer,ILHConsumerResultsWrapper>();
        
        if (lstSFMatches != null) {//Adding sf results to a map
            for (integer i=0;i<lstSFMatches.size();i++) {
                mapSFContacts.put(i,lstSFMatches.get(i));
            }
        }
        if (lstCPSMatches != null) {//Adding cps results to a map
            for (integer i=0;i<lstCPSMatches.size();i++) {
                mapCPSContacts.put(i,lstCPSMatches.get(i));
            }
        }                                                       
        /* Merge rules between SalesForce and CPS are based on the following:
            1. Match on the Contact.Id = SourceSystemProductKey (when SourceSystem is SF)
            2. Match on the PersonId
            3. Match on First Name, Last Name, Date of Birth as they are available
        */
        if (lstCPSMatches != null) {
            for (integer cpsInt : mapCPSContacts.keySet()) {
                ILHConsumerResultsWrapper cpsRecord = mapCPSContacts.get(cpsInt);
                for (integer sfInt : mapSFContacts.keySet()) {
                    ILHConsumerResultsWrapper sfRecord = mapSFContacts.get(sfInt);
                    Boolean keyFound = false;

                    if (cpsRecord.sourceSystemKeys != null) {
                        for (String sourceKey : cpsRecord.sourceSystemKeys) {//Iterating through source system keys on the cps row
                            //If the person contact id on sf row and the source system id on cps row are equal.
                            if (sfRecord?.sourceSystemKeys != null && !sfRecord.sourceSystemKeys.isEmpty() && sourceKey == sfRecord.sourceSystemKeys[0]) {
                                keyFound = true;//Key has beeen found
                                break;//We don't need to check next source key
                            }
                        }
                    } 
                    if (cpsRecord.personId == sfRecord.personId) {//If sf and cps person id are equal, then remove current sf row
                        lstMergeset.add(cpsRecord);
                        mapSFContacts.remove(sfInt);
                        mapCPSContacts.remove(cpsInt);   
                        break;         
                    } 
                    else if (keyFound) {//If source system key is found on the sf person, then remove current sf row
                        lstMergeset.add(cpsRecord);
                        mapSFContacts.remove(sfInt);
                        mapCPSContacts.remove(cpsInt);
                        break;
                    }
                    //If sf first name is equal to cps first name and sf last name is equal to cps last name and sf DOB is equal to cps DOB, then remove current sf row
                    else if (sfRecord.firstName == cpsRecord.firstName && sfRecord.lastName == cpsRecord.lastName && sfRecord.dateOfBirth == cpsRecord.dateOfBirth) { 
                        lstMergeset.add(cpsRecord);
                        mapSFContacts.remove(sfInt);
                        mapCPSContacts.remove(cpsInt);
                        break;
                    }
                }
            }
            lstMergeset.addAll(mapCPSContacts.values());//Add all remaining cps records to the list to merge
        }
        if (lstSFMatches != null) {
            lstMergeset.addAll(mapSFContacts.values());//Add all remaining sf records to the list to merge
        }

        Set<ILHConsumerResultsWrapper> resultSet = new Set<ILHConsumerResultsWrapper>();
        List<ILHConsumerResultsWrapper> resultList = new List<ILHConsumerResultsWrapper>();
        for (ILHConsumerResultsWrapper s : lstMergeSet) {
            if (resultSet.add(s)) {//If elements in the current record are not equal to elements in another record
                resultList.add(s);
            }
        }
        return resultList;
    }
}