/**
 * Copyright: TruStage
 * Purpose: This class will combine cps search results with Salesforce.
 * Details    :  Remove duplicate rows
 *               Match on Person ID
 *               Match on Person Account ID    
 *               Match on FN, LN, DOB
 *               From match, always take CPS info:  FN, MN, LN, Suffix, Person ID, SSN, DOB, Address, Gender, Home phone, Cell phone, work phone, deceased, plus SF Person Account Id
 *               If no CPS match for a SF records, include that record in the search results with SF data for the same fields
 *               Use the deduped list for search results 
 */
public class ILHSearchMergeImpl {    
    /**
     * Purpose: This method determines if a row is from cps or sf, and then adds the row to the correct list
     * @param searchResults  : List of all results
     * @return : List of merged results
     */
    public ILHConsumerResultsWrapper mergeResults(List<ILHConsumerResultsWrapper> wrappers){
        List<ILHConsumerResultsWrapper.SearchResult> sfResults = new List<ILHConsumerResultsWrapper.SearchResult>();//Set that contains results from Salesforce
        List<ILHConsumerResultsWrapper.SearchResult> cpsResults = new List<ILHConsumerResultsWrapper.SearchResult>();//List that contains merged resutlts from SF and CPS   
        
        for (ILHConsumerResultsWrapper sr : wrappers) {//Looping through all search results
            if (sr.results != null) {
                if (sr.mySource == ILHConsumerResultsWrapper.Source.CPS) {//Search result is from CPS
                    cpsResults.addAll(sr.results);
                } else if (sr.mySource == ILHConsumerResultsWrapper.Source.SALESFORCE) {//Search result is from Salesforce
                    sfResults.addAll(sr.results);
                }
            }
        }
        return mergeResultset(wrappers, sfResults, cpsResults);
    }

    /**
     * Purpose: This method merges sf results with cps results
     * @param lstSFMatches  : List of sf results
     * @param lstCPSMatches  : List of cps results
     * @return : List of merged results
     */
    private ILHConsumerResultsWrapper mergeResultset(List<ILHConsumerResultsWrapper> wrappers, List<ILHConsumerResultsWrapper.SearchResult> lstSFMatches, List<ILHConsumerResultsWrapper.SearchResult> lstCPSMatches) {
                                                                
        List<ILHConsumerResultsWrapper.SearchResult> lstMergeset = new List<ILHConsumerResultsWrapper.SearchResult>();
        Map<Integer,ILHConsumerResultsWrapper.SearchResult> mapSFContacts = new Map<Integer,ILHConsumerResultsWrapper.SearchResult>();
        Map<Integer,ILHConsumerResultsWrapper.SearchResult> mapCPSContacts = new Map<Integer,ILHConsumerResultsWrapper.SearchResult>();
        
        if (lstSFMatches != null) {//Adding sf results to a map
            for (integer i=0;i<lstSFMatches.size();i++) {
                ILHConsumerResultsWrapper.SearchResult sfRecord = lstSFMatches.get(i);
                sfRecord.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
                mapSFContacts.put(i,sfRecord);
            }
        }
        if (lstCPSMatches != null) {//Adding cps results to a map
            for (integer i=0;i<lstCPSMatches.size();i++) {
                ILHConsumerResultsWrapper.SearchResult cpsRecord = lstCPSMatches.get(i);
                cpsRecord.mySource = ILHConsumerResultsWrapper.Source.CPS;
                mapCPSContacts.put(i,cpsRecord);
            }
        }                                                       
        /* Merge rules between SalesForce and CPS are based on the following:
            1. Match on the Contact.Id = SourceSystemProductKey (when SourceSystem is SF)
            2. Match on the PersonId
            3. Match on First Name, Last Name, Date of Birth as they are available
        */
        if (lstCPSMatches != null) {
            for (integer cpsInt : mapCPSContacts.keySet()) {
                ILHConsumerResultsWrapper.SearchResult cpsRecord = mapCPSContacts.get(cpsInt);
                for (integer sfInt : mapSFContacts.keySet()) {
                    ILHConsumerResultsWrapper.SearchResult sfRecord = mapSFContacts.get(sfInt);
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
                        lstMergeset.add(mergeContact(sfRecord, cpsRecord));
                        mapSFContacts.remove(sfInt);
                        mapCPSContacts.remove(cpsInt);   
                        break;         
                    } 
                    else if (keyFound) {//If source system key is found on the sf person, then remove current sf row
                        lstMergeset.add(mergeContact(sfRecord, cpsRecord));
                        mapSFContacts.remove(sfInt);
                        mapCPSContacts.remove(cpsInt);
                        break;
                    }
                    //If sf first name is equal to cps first name and sf last name is equal to cps last name and sf DOB is equal to cps DOB, then remove current sf row
                    else if (sfRecord.firstName == cpsRecord.firstName && sfRecord.lastName == cpsRecord.lastName && sfRecord.dateOfBirth == cpsRecord.dateOfBirth) { 
                        lstMergeset.add(mergeContact(sfRecord, cpsRecord));
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

        Set<ILHConsumerResultsWrapper.SearchResult> resultSet = new Set<ILHConsumerResultsWrapper.SearchResult>();
        List<ILHConsumerResultsWrapper.SearchResult> resultList = new List<ILHConsumerResultsWrapper.SearchResult>();
        ILHConsumerResultsWrapper mergedWrapper = new ILHConsumerResultsWrapper();

        for (ILHConsumerResultsWrapper.SearchResult s : lstMergeSet) {
            if (resultSet.add(s)) {//If elements in the current record are not equal to elements in another record
                resultList.add(s);
            }
        }

        for (ILHConsumerResultsWrapper wrapper : wrappers) {//Merging errors into one wrapper
            mergedWrapper.errors.addAll(wrapper.errors);
        }

        mergedWrapper.results = resultList;
        return mergedWrapper;
    }

    /**
     * Purpose: This method maps a CPS record to SF record
     * @param sfWrapper  : SF record to map to
     * @param cpsWrapper  : CPS record to map
     * @return : Mapped wrapper result
     */
    @TestVisible
    private ILHConsumerResultsWrapper.SearchResult mergeContact(ILHConsumerResultsWrapper.SearchResult sfWrapper, ILHConsumerResultsWrapper.SearchResult cpsWrapper) {
        String sfId = sfWrapper.sourceSystemKeys[0];
        String mobile = sfWrapper.mobilePhone;
        sfWrapper = cpsWrapper;
        sfWrapper.sourceSystemKeys = new List<String>{sfId};//Do not overwrite SF id
        sfWrapper.mobilePhone = mobile; // Retain Salesforce mobile number
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        return sfWrapper;
    }
}