/**
 * Copyright: TruStage
 * Purpose: Unit tests for the EligibleRateService class
 */
@isTest
private class EligibleRateServiceTests {

    @testSetup static void recordSetup() {
        Date newDate = Date.newInstance(1979, 9, 7);

        Id objectRecordTypeId = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'].id;

        // Create common test accounts
        Account accnt = new Account(
            FirstName = 'Test',
            LastName = 'User',
            PersonMailingState = 'WI',
            PersonBirthdate = newDate,
            PersonMailingStreet = '123 Some Street',
            RecordTypeId = objectRecordTypeId
        );
        insert accnt;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = accnt.id,
            TobaccoUse__c = 'No',
            StageName = 'Quote',
            InsurancePurpose__c = 'Gift',
            HealthAssessment__c = 'No Health Issues',
            ProposedCoverage__c = 50000,
            CloseDate = Date.today()
        );
        insert opp;
    }

    @isTest
    static void getRatesTest() {
        //Creating a mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockProductQuoteResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'Test Opp'].id;
        Test.startTest();
        EligibleProductRateWrapper result = new EligibleRateService().getRates(oppId);
        Assert.isNotNull(result, 'Result is not null');
    }
}