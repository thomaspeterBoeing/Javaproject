/***
Copyright: TruStage
Purpose: Provides unit testing and code coverage for MarketingHistoryController class.
1.0 - Adam Perschke-Ely - 11/2/2023  - Created for new D2C Salesfore instance.
***/
@isTest
public class MarketingHistoryControllerTests {
    @isTest
    private static void searchHistoryTest() {
        //Creating a mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockMarketingHistoryResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        MockMetadataUtils.insert_custom_metadata_mock();
        
        Test.startTest();
        Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
        kvpSearchCriteria.put('personId', '1234');
        List<ILHMarketingHistoryResultsWrapper> results = MarketingHistoryController.getMarketHistory(kvpSearchCriteria);
        Assert.areEqual(4, results.size());
    }
}