/***
Copyright: TruStage
Purpose: Provides unit testing and code coverage for ILHMarketingHistory class.
1.0 - Adam Perschke-Ely - 11/2/2023  - Created for new D2C Salesfore instance.
***/
@isTest
public class ILHMarketingHistoryTests {
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
        List<ILHMarketingHistoryResultsWrapper> results = (new ILHMarketingHistory()).getMarketHistory(kvpSearchCriteria);

        //Verifying that there are 4 results.  
        //There's 5 records in the mock response, but the 5th record is greater than 365 old and shouldn't be add to the list
        //And the contact date on the 6th record is null and shouldn't be added to the list
        Assert.areEqual(4, results.size());
        Assert.areEqual('1009877134222', results[0].sourceId);
        Assert.areEqual('0622 SIWL NB Letter New Creative Strategy', results[0].offerDescription);
        Assert.areEqual('2QWP', results[0].campaignProduct);
        Assert.areEqual('DirectMail', results[0].channelCode);
        Assert.areEqual('11111111', results[0].contractNumber);
        Assert.areEqual(Date.newInstance(3023, 07, 10), results[0].mailingDate);

        //Causing an Exception
        try {
            results = (new ILHMarketingHistory()).getMarketHistory(null);
        } catch(Exception ex) {}

        //Testing with no person id with null value
        kvpSearchCriteria = new Map<String, Object>();
        kvpSearchCriteria.put('personId', null);
        results = (new ILHMarketingHistory()).getMarketHistory(kvpSearchCriteria);
        Assert.areEqual(0, results.size());
    }
}