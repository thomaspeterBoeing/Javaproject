/**
 * Copyright: TruStage
 * Purpose: Unit tests for ConsumerSearchController class
 */
@isTest
public class ConsumerSearchControllerTests {
    static final String SAMPLE_PERSON_ID = '2000000081816';

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
            kvpSearchCriteria.put('ssn', '111111111');

            Test.startTest();
            ILHConsumerResultsWrapper wrapper = ConsumerSearchController.search(kvpSearchCriteria);
            //Verifying search results
            Assert.IsTrue(wrapper.results.size() > 0);
            Boolean isPersonIdInSearch = false;
            for (ILHConsumerResultsWrapper.SearchResult item : wrapper.results) {
                if (item.personId == SAMPLE_PERSON_ID) {
                    isPersonIdInSearch = true;
                }
            }
            Assert.isTrue(isPersonIdInSearch);
        }
    }

    @isTest
    public static void checkPhoneExclusionFlag_Test() {
        string phone = '(123) 1231234';
        Boolean ret = ConsumerSearchController.checkPhoneExclusionFlag(phone);
        Assert.isFalse(ret);
    }
}