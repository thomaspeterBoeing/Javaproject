@isTest
public with sharing class ILHPolicySearchTests {
    private static String SearchCriteria =  '3000002675906';

    @testSetup static void setup() {
        Date newDate = Date.newInstance(2017, 11, 02);

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
            PersonID__pc = '3000002675906',
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
    private static void testCPSSearch () {
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('Mock_PolicySummaryResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/xml');
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            List<ILHPolicyResultsWrapper> resultsWrapper = (new ILHPolicySearch()).search(SearchCriteria);
            Assert.areEqual(7, resultsWrapper.size());

            Assert.areEqual('EBIXLIFE', resultsWrapper[0].SourceSystemId);
            Assert.areEqual('COMPLETED', resultsWrapper[0].Status);
            Assert.areEqual('51LC0234688', resultsWrapper[0].ProductNumber);
            Assert.areEqual('Insured', resultsWrapper[0].ProductRelationshipDescription);
        }
    }
}