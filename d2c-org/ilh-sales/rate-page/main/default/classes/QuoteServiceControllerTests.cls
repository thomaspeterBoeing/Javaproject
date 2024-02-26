/**
 * Copyright: TruStage
 * Purpose: Unit tests for the QuoteServiceController class
 */
@isTest
private class QuoteServiceControllerTests {

    @testSetup static void recordSetup() {
        Date newDate = Date.newInstance(1979, 9, 7);

        Id objectRecordTypeId = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'].id;
        Id affiliationRecordTypeId = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'Affiliation' AND SobjectType = 'Account'].id;

        // Create common test accounts
        Account accnt = new Account(
            FirstName = 'Test',
            LastName = 'User',
            Gender__pc = 'Male',
            PersonMailingState = 'WI',
            PersonBirthdate = newDate,
            PersonMailingStreet = '123 Some Street',
            RecordTypeId = objectRecordTypeId
        );
        insert accnt;

        Account affiliationAcc = new Account(
            Name = 'Test Credit Union',
            ContractNumberUnformatted__c = '11111111',
            RecordTypeId = affiliationRecordTypeId
        );
        insert affiliationAcc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            Affiliation__c = affiliationAcc.id,
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

        Map<String, Object> requestMap = new Map<String, Object> {
            'frequency' => 'monthly',
            'billingMethodCode' => 'ACH',
            'productCategory' => 'Life',
            'oppId' => oppId
        };

        Test.startTest();
        EligibleProductRateWrapper wrapper = QuoteServiceController.getRates(requestMap);
        Assert.isNotNull(wrapper, 'A wrapper result should be returned');
        Test.stopTest();
    }
}