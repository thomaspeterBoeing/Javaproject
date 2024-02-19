/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ILHSearchService class
 */
@isTest
public class ILHSearchServiceTests {
    @testSetup 
    public static void setupUsers() {
        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User adminUser = new User(Alias = 'adminu', Email='testadminuser@test.com', Persona__c = 'System Admin',
            EmailEncodingKey='UTF-8', FirstName='Admin', LastName='User', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@testadminuser.com');
        insert adminUser;
    }

    @isTest
    public static void searchTest() {
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {

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
}
