/***
Copyright: TruStage
Purpose: Provides unit testing and code coverage for MarketingHistoryController class.
1.0 - Adam Perschke-Ely - 11/2/2023  - Created for new D2C Salesfore instance.
***/
@isTest
public class MarketingHistoryControllerTests {
    @testSetup 
    public static void setupUsers() {
        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User adminUser = new User(Alias = 'adminu', Email='testadminuser@test.com', Persona__c = 'System Admin',
            EmailEncodingKey='UTF-8', FirstName='Admin', LastName='User', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@testadminuser.com');
        insert adminUser;
    }

    @isTest
    private static void searchHistoryTest() {
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {
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
}