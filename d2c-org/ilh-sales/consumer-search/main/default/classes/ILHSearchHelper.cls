/**
 * Copyright: TruStage
 * Purpose: Apex Class to build reusable objects for Consumer Search 
 */
public with sharing class ILHSearchHelper {
    public static final Integer MAX_QUERY_RESULTS = 50;//Indicates how many SF Account records we should return from SF
    public static final String POSTAL_CODE_FIELD_NAME = 'PersonMailingPostalCode';
    public static final String BIRTH_DATE_FIELD_NAME = 'PersonBirthdate';

    /**
     * Purpose: This method tansforms kvp criteria to request object
     * @param kvpSearchCriteria : kvp's in the form of search criteria
     * @param maxResultsToReturn : number of results that should be returned from the service
     * @return : Transformed request object
     */
    public static ConsumerProfileServiceRequest createCPSSearchRequest(Map<String, Object> kvpSearchCriteria,integer maxResultsToReturn) {
        ConsumerProfileServiceRequest.SearchCriteria searchCriteria = createSearchCriteria(kvpSearchCriteria);

        ConsumerProfileServiceRequest.SearchConsumerProfileType searchProfile = new ConsumerProfileServiceRequest.SearchConsumerProfileType(searchCriteria);

        //Setting the types of elements to return from the service
        ConsumerProfileServiceRequest.SearchRequestInfoType searchInfo = new ConsumerProfileServiceRequest.SearchRequestInfoType();
        searchInfo.setElementsToReturn(
            new List<ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn> {
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.ADDRESS,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.BIRTHDATE,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.NAME,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.PERSONID,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.PHONE,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.TAXIDLASTFOUR,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.GENDER,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.SOURCERECORD,
                ConsumerProfileServiceRequest.SearchRequestInfoType_enumElementsToReturn.TAXID
            }
        );
        searchInfo.MaxResultsToReturn = maxResultsToReturn;//Set max number of records to return from service
        return new ConsumerProfileServiceRequest(searchProfile, searchInfo);
    }
    
    /**
     * Purpose: This method tansforms kvp criteria to Search Criteria object
     * @param kvpSearchCriteria : kvp's in the form of search criteria
     * @return : Transformed Search Criteria object
     */
    public static ConsumerProfileServiceRequest.SearchCriteria createSearchCriteria(Map<String, Object> kvpSearchCriteria) {
        String criteriaString = JSON.serialize(kvpSearchCriteria);
        return (ConsumerProfileServiceRequest.SearchCriteria)JSON.deserialize(criteriaString, ConsumerProfileServiceRequest.SearchCriteria.class);
    }
  
    /**
     * Purpose: This method searches Salesforce for SF contacts
     * @param cpsRequest : Consumer Profile Service Request
     * @return : Returns a List of search results from CPS
     */
    public static ILHConsumerResultsWrapper searchCPS(ConsumerProfileServiceRequest cpsRequest) {
        //No request sent to method, so return null
        if (cpsRequest == null) {
            return null;
        }
        ILHConsumerResultsWrapper wrapper = new ILHConsumerResultsWrapper();
        wrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;

        //Remove all formatting from Phone Number
        if (cpsRequest?.SearchConsumerProfile?.phoneNumber != null) {
            cpsRequest.SearchConsumerProfile.PhoneNumber = Utilities.removeAllPhoneFormatting(cpsRequest.SearchConsumerProfile.phoneNumber);
        }

        //Create request payload
        String requestPayload = JSON.serialize(cpsRequest, true);
        HttpResponse response;

        try {
            //Call CPS search service
            response = HttpHelper.sendAPICRequest('CPS_Search',requestPayload);

            //Retrieving DataWeave script and getting the mapped data back
            DataWeave.Script script = new DataWeaveScriptResource.consumerSearch();
            DataWeave.Result dwresult = script.execute(new Map<String, Object>{'payload' => response.getBody()});
            List<Object> results = (List<Object>)dwresult?.getValue();//Need to cast results to a list of object before casting to wrapper to check for null or empty result
            if (results != null && !results.isEmpty()) {
                wrapper.results = (List<ILHConsumerResultsWrapper.SearchResult>)dwresult?.getValue();
                wrapper.applyBusinessRules();
            }
        } catch (Exception ex) {
            wrapper.errors.add('The Consumer Profile Service is currently unavailable. Search results will be impacted. Please proceed with creating a new consumer as needed.');
            new ErrorLogger(ex, null, 'ILHSearchHelper.cls', null, 'CPS Search', requestPayload, 'CPS_Search', response?.getStatusCode());
        }
        return wrapper;
    }  

    /**
     * Purpose: This method searches Salesforce for SF contacts
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return : Returns a List of search results from Salesforce 
     */
    public static ILHConsumerResultsWrapper searchSF(Map<String, Object> kvpSearchCriteria, List<ILHConsumerResultsWrapper> wrappers) {
        Boolean isValidSearchCriteria = true;
        Boolean blnSkipSFSearch = false;
        String optionalSearchCriteria = '';
        String soqlClause = '';
        Map<String, Object> queryParams = new Map<String, Object>();

        ILHConsumerResultsWrapper newWrapper = new ILHConsumerResultsWrapper();
        newWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;

        //Variables that hold data from search criteria
        String ssn = (String)kvpSearchCriteria.get('ssn');
        String policyNumber = (String)kvpSearchCriteria.get('policyNumber');
        String firstName = (String)kvpSearchCriteria.get('firstName');
        String lastName = (String)kvpSearchCriteria.get('lastName');
        String birthDate = (String)kvpSearchCriteria.get('dateOfBirth');
        String phoneNumber = (String)kvpSearchCriteria.get('phoneNumber');
        String zipCode = (String)kvpSearchCriteria.get('zipCode');
        String state = (String)kvpSearchCriteria.get('state');

        if (String.isNotEmpty(phoneNumber)) {//Remove formatting from phone numbers. Example: (111) 111-1111 to 1111111111
            phoneNumber = Utilities.removeAllPhoneFormatting(phoneNumber);
        }

        if (String.isNotEmpty(birthDate)) {//Format date from 01/01/2023 to 2023-01-01
            birthDate = Utilities.DateFormatSwitchMMDDYYYTtoYYYYMMDD(birthDate);
        }

        //Starting SOQL statement
        string soql = 'SELECT Id, FirstName, LastName, PersonMailingCity, PersonMailingStreet, PersonMailingState, PersonMailingPostalCode,'+
            'SSNLast4__pc, Gender__pc, PersonMobilePhone, PersonHomePhone, Suffix, PersonID__pc, PersonBirthdate, PersonContactId, PersonOtherPhone' +
            ' FROM Account WHERE ';

        //Combination 1: Social Security Number (Contact.SSN__c)
        //Removing ssn from search criteria since we won't be searching SF for ssn
        if (String.isNotEmpty(ssn)) {
            if (wrappers == null || wrappers?.isEmpty()) {
                blnSkipSFSearch = true;
            }
        }
        //Combination 2: Policy Number
        else if (String.isNotEmpty(policyNumber)) {
            if (wrappers == null || wrappers?.isEmpty()) {
                blnSkipSFSearch = true;
            }
        } 
        // Combination 3: Phone number && (FN or LN or ZIP)
        else if (String.isNotEmpty(phoneNumber) && (String.isNotEmpty(firstName) || String.isNotEmpty(lastName) || String.isNotEmpty(zipCode))) {
            soqlClause += buildNameSearchFields(firstName, lastName, zipCode, POSTAL_CODE_FIELD_NAME, queryParams);
            soqlClause += ' AND ' + buildPhoneNumberSearchFields(phoneNumber, queryParams);
            optionalSearchCriteria = buildOptionalSearchFields(birthdate, state, queryParams);
            if (String.isNotEmpty(optionalSearchCriteria)) {
                soqlClause += ' AND ' + optionalSearchCriteria;
            }
        } 
        // Combination 4: Phone number
        else if (String.isNotEmpty(phoneNumber)) { 
            soqlClause += buildPhoneNumberSearchFields(phoneNumber,queryParams);
            optionalSearchCriteria = buildOptionalSearchFields(birthdate, state, queryParams);
            if (String.isNotEmpty(optionalSearchCriteria)) {
                soqlClause += ' AND ' + optionalSearchCriteria;
            }
        } 
        // Combination 5: FN,LN,ZIP
        else if (String.isNotEmpty(firstName) && String.isNotEmpty(lastName) && String.isNotEmpty(zipCode)) {
            soqlClause += buildNameSearchFields(firstName, lastName, zipCode, POSTAL_CODE_FIELD_NAME, queryParams);
            optionalSearchCriteria = buildOptionalSearchFields(birthdate, state, queryParams);
            if (String.isNotEmpty(optionalSearchCriteria)) {
                soqlClause += ' AND ' + optionalSearchCriteria;
            }
        } 
        // Combination 6: FN,LN,DOB
        else if (String.isNotEmpty(firstName) && String.isNotEmpty(lastName) && String.isNotEmpty(birthDate)) { 
            soqlClause += buildNameSearchFields(firstName, lastName, birthdate, BIRTH_DATE_FIELD_NAME, queryParams);
            optionalSearchCriteria = buildOptionalSearchFields(null, state, queryParams);//Don't need to pass birthdate a second time
            if (String.isNotEmpty(optionalSearchCriteria)) {
                soqlClause += ' AND ' + optionalSearchCriteria;
            }
        }
        else {
            isValidSearchCriteria = false;
        }
        //Search criteria is vailid
        if (isValidSearchCriteria) {
            List<Account> sfAccounts;

            if (String.isNotEmpty(soqlClause)) {
                soql += '(' + soqlClause + ')';
            }

            //Building query for person id and account id
            String keyFields;
            if (wrappers != null) {
                keyFields = buildKeyMatchSearchFields(wrappers, queryParams);
            }
            if (String.isNotEmpty(keyFields)) {
                //There's additional filtering after WHERE.  Add AND so we and add in filtering for account and person id
                if (String.isNotEmpty(soqlClause)) {
                    soql += ' OR (';
                }

                //Add in the the filtering for account and person id
                soql += keyFields;

                //There's additional filtering after WHERE.  Close out the filter call for account and person id
                if (String.isNotEmpty(soqlClause)) {
                    soql += ')';
                }
            } else {
                if (String.isEmpty(soqlClause)) {//Skip SF search because nothing to query on
                    blnSkipSFSearch = true;
                }
            }

            //Call SalesForce to retrieve consumer details
            if (!blnSkipSFSearch) {
                //Setting the max number of results to receive in the query
                soql += ' LIMIT ' + MAX_QUERY_RESULTS;

                try {
                    sfAccounts = Database.queryWithBinds(soql, queryParams, AccessLevel.USER_MODE);
                } catch(Exception ex) {
                    new ErrorLogger(ex, null, 'ILHSearchHelper.cls', null, 'SF Search', null, null, null);
                }
            }

            //Map the account records from the query to ILHConsumerResultsWrapper class
            if (sfAccounts != null && !sfAccounts.isEmpty()) {
                newWrapper.results = mapSFAccountToResultWrapper(sfAccounts);
            }
            return newWrapper;
        }           
        return null;
    }

    /**
     * Purpose: This method maps SF Accounts fields to result wrapper fields so that we can easily iterate over results on consumer search page
     * @param sfAccounts  : List of results from CPS that contains person ids and person account ids that we need to extract
     * @return : A list of ILHConsumerResultsWrappers that have been mapped from SF accounts
     */
    private static List<ILHConsumerResultsWrapper.SearchResult> mapSFAccountToResultWrapper(List<Account> sfAccounts) {
        List<ILHConsumerResultsWrapper.SearchResult> mappedResults = new List<ILHConsumerResultsWrapper.SearchResult>();
        for (Account accnt : sfAccounts) {
            mappedResults.add(new ILHConsumerResultsWrapper.SearchResult(accnt));
        }
        return mappedResults;
    }

    /**
     * Purpose: This method builds filter criteria for an Account query for person ids and account ids
     * @param wrappers  : List of results from CPS that contains person ids and person account ids that we need to extract
     * @param queryParams  : Contains kvp's to use in queryWithBinds
     * @return : Portion of SOQL clause
     */
    private static string buildKeyMatchSearchFields(List<ILHConsumerResultsWrapper> wrappers, Map<String, Object> queryParams) {
        String retSFValue = '';
        String retServiceValue = '';
        List<String> contactIds = new List<String>();//List of Person Accont ids from CPS
        List<String> personIds = new List<String>();//List of Person ids from CPS

        //Itterate over the results found from the service
        for (ILHConsumerResultsWrapper wrapper : wrappers) {
            if (wrapper?.results != null && !wrapper.results.isEmpty()) {
                for (ILHConsumerResultsWrapper.SearchResult searchResult : wrapper.results) {
                    if (searchResult?.sourceSystemKeys != null && !searchResult.sourceSystemKeys.isEmpty()) {
                        for (String contactId : searchResult.sourceSystemKeys) {
                            contactIds.add(contactId);
                        }
                    }
                    if (String.isNotEmpty(searchResult?.personId)) {
                        personIds.add(searchResult.personId);
                    }
                }
            }
        }
        if (contactIds != null && !contactIds.isEmpty()) { // remove the last comma            
            retSFValue = 'PersonContactId IN:contactIds';
            queryParams.put('contactIds', contactIds);
        }
        if (personIds != null && !personIds.isEmpty()) {
            retServiceValue = 'PersonID__pc IN:personIds';
            queryParams.put('personIds', personIds);
        }
        if (String.isNotBlank(retSFValue) && String.isNotBlank(retServiceValue)) {
            return  retSFValue + ' OR ' + retServiceValue;
        } else if (String.isNotBlank(retSFValue) || String.isNotBlank(retServiceValue)) {
            return  retSFValue + retServiceValue;
        } else {
            return '';
        }
    }

    /**
     * Purpose: This method builds filter criteria for an Account query for first name, last name and zip code fields
     * @param firstName  : First name value entered from consumer search page
     * @param lastName  : Last name value entered from consumer search page
     * @param additionalFieldVal  : Additional field value entered from consumer search page
     * @param additionalFieldName  : Field name of additional field that we want to search on
     * @param queryParams  : Contains kvp's to use in queryWithBinds
     * @return : Portion of SOQL clause
     */
    private static String buildNameSearchFields(string firstName, string lastName, String additionalFieldVal, String additionalFieldName, Map<String, Object> queryParams) {
        string retVal = '';
        if (String.isNotEmpty(firstName)) {
            firstName = String.escapeSingleQuotes(firstName);
            if (firstName.contains('*')) {
                retVal += 'FirstName LIKE :firstName';
                queryParams.put('firstName', firstName.replace('*','%'));
            } else {
                retVal += 'FirstName =:firstName';
                queryParams.put('firstName', firstName);
            }
        }
        if (String.isNotEmpty(lastName)) {
            lastName = String.escapeSingleQuotes(lastName);
            if (retVal != '') {
                retVal += ' AND ';
            }
            if (lastName.contains('*')) {
                retVal += 'LastName LIKE :lastName';
                queryParams.put('lastName', lastName.replace('*','%'));
            } else {
                retVal += 'LastName =:lastName';
                queryParams.put('lastName', lastName);
            }
        }
        if (String.isNotEmpty(additionalFieldName) && String.isNotEmpty(additionalFieldVal)) {
            additionalFieldVal = String.escapeSingleQuotes(additionalFieldVal);
            if (retVal != '') {
                retVal += ' AND ';
            }
            if (additionalFieldName == POSTAL_CODE_FIELD_NAME) {
                retVal += 'PersonMailingPostalCode LIKE :postalCode';
                queryParams.put('postalCode', additionalFieldVal.substring(0,5) + '%');
            } else if (additionalFieldName == BIRTH_DATE_FIELD_NAME) {
                retVal += 'PersonBirthdate =:birthDate';
                queryParams.put('birthDate', Date.valueOf(additionalFieldVal));
            }
        }
        return retVal;
    }

    /**
     * Purpose: This method builds filter criteria for an Account query for phone number fields.
     * @param phoneNumber  : Phone number value entered from consumer search page
     * @param queryParams  : Contains kvp's to use in queryWithBinds
     * @return : Portion of SOQL clause
     */
    private static String buildPhoneNumberSearchFields(String phoneNumber, Map<String, Object> queryParams) {
        string retVal;
        phoneNumber = String.escapeSingleQuotes(phoneNumber);
        retVal = '(PersonHomePhone =:phone';
        retVal += ' OR PersonMobilePhone =:phone';
        retVal += ' OR PersonOtherPhone =:phone';
        retVal += ' OR Fax =:phone)';
        queryParams.put('phone', phoneNumber);
        return retVal;
    }

    /**
     * Purpose: This method builds filter criteria for an Account query for birth date, and state fields
     * @param birthDate  : Birthdate value entered from consumer search page
     * @param state  : State value entered from consumer search page
     * @param queryParams  : Contains kvp's to use in queryWithBinds
     * @return : Portion of SOQL clause
     */
    private static String buildOptionalSearchFields(String birthDate, String state, Map<String, Object> queryParams) {
        string retSearchFields = '';

        if (String.isNotEmpty(birthDate)) {
            retSearchFields += 'PersonBirthdate =:birthDate';
            queryParams.put('birthDate', Date.valueOf(birthDate));
        }
        if (String.isNotEmpty(state)) {
            if (String.isNotEmpty(retSearchFields)) {
                retSearchFields += ' AND ';
            }
            retSearchFields += 'PersonMailingState =:state';
            queryParams.put('state', String.escapeSingleQuotes(state));
        }
        return retSearchFields;
    }
}