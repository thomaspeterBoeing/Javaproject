/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ILHConsumerSearch class
 */
@isTest
public class ILHConsumerSearchTests {
    @testSetup
    static void setup() {
        Date newDate = Date.newInstance(1979, 9, 7);

        Id objectRecordTypeId = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'].id;

        // Create common test accounts
        Account accnt = new Account(
            FirstName = 'Test',
            LastName = 'User',
            PersonMailingCity = 'Madison',
            PersonMailingState = 'WI',
            PersonMailingPostalCode = '537194031',
            PersonMobilePhone = '6109210331',
            PersonHomePhone = '6109210331',
            PersonBirthdate = newDate,
            PersonID__pc = '2000000081816',
            PersonMailingStreet = '3901 MAMMOTH TRL',
            RecordTypeId = objectRecordTypeId
        );
        insert accnt;

        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User adminUser = new User(Alias = 'adminu', Email='testadminuser@test.com', Persona__c = 'System Admin',
            EmailEncodingKey='UTF-8', FirstName='Admin', LastName='User', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@testadminuser.com');
        insert adminUser;
    }

    @isTest
    private static void searchTest() {
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {
            Map<String, Object> kvpSearchCriteria = new Map<String, Object>{
                'ssn' => '111111111'
            };
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('mock_ConsumerProfileSearchResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            List<ILHConsumerResultsWrapper> resultsWrapper = (new ILHConsumerSearch()).search(kvpSearchCriteria);
            Assert.areEqual(2, resultsWrapper.size(), '2 wrapper results: CPS and SF ');
        }
    }
}