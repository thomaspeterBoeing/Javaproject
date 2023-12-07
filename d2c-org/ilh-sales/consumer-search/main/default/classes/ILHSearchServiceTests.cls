/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ILHSearchService class
 */
@isTest
public class ILHSearchServiceTests {
    @isTest
    public static void searchTest() {
        //Creating a succesful mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('mock_ConsumerProfileSearchResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        //Creating initial search criteria for request
        Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
        kvpSearchCriteria.put('firstName', 'First');
        kvpSearchCriteria.put('lastName', 'Last');
        kvpSearchCriteria.put('phoneNumber', '(111) 111-1111');

        Test.startTest();
        ILHConsumerResultsWrapper wrapper = (new ILHSearchService()).runSearch(kvpSearchCriteria);
        //Verifying search results
        Assert.IsTrue(wrapper.results.size() > 0, 'Expecting more than 1 result');
    }
}
