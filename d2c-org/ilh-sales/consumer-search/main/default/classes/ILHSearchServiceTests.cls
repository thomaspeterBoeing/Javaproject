/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ILHSearchService class
 */
@isTest
public class ILHSearchServiceTests {
    static final String SAMPLE_PERSON_ID = '2000000081816';
    @isTest
    public static void searchTest(){
        //Creating a succesful mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('mock_ConsumerProfileSearchResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock); 
        MockMetadataUtils.insert_custom_metadata_mock();

        //Creating initial search criteria for request
        Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
        kvpSearchCriteria.put('firstName','First');
        kvpSearchCriteria.put('lastName','Last');
        kvpSearchCriteria.put('phoneNumber','(111) 111-1111');
        kvpSearchCriteria.put('state', 'NC');
        kvpSearchCriteria.put('ssn','1111');
        kvpSearchCriteria.put('policyNumber','1111');
        kvpSearchCriteria.put('dateOfBirth','1/1/2023');
        
        Test.startTest();
        ILHConsumerResultsWrapper wrapper = (new ILHSearchService()).runSearch(kvpSearchCriteria);
        //Verifying search results        
        Assert.IsTrue(wrapper.results.size()>0, 'Expecting more than 1 result');
    }
}