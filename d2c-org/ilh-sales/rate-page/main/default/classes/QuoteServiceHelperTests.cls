/**
 * Copyright: TruStage
 * Purpose: Unit tests for the QuoteServiceHelper class
 */
@isTest
private with sharing class QuoteServiceHelperTests {

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
            'billingMethodCode' => 'ACH/PAC',
            'productCategory' => 'Life',
            'oppId' => oppId
        };

        Test.startTest();
        EligibleProductRateWrapper result = new QuoteServiceHelper().getRates(requestMap);
        Assert.isNotNull(result, 'Result is not null');
        Test.stopTest();
    }

    @isTest
    static void getQuoteRequestMapTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'Test Opp'].id;
        Map<String, Object> requestMap = new Map<String, Object> {
            'frequency' => 'monthly',
            'billingMethodCode' => 'ACH',
            'productCategory' => 'Life',
            'oppId' => oppId
        };

        Test.startTest();
        Map<String, Object> rateRequest = new QuoteServiceHelper().getQuoteRequestMap(requestMap);
        Assert.areEqual(300000, rateRequest.get('maxCoverage'), 'Max coverage is equal to upper bound value from rate comparison interval table');
        Assert.areEqual(1000, rateRequest.get('minCoverage'), 'Min coverage is equal to lower bound value from rate comparison interval table');
        Assert.areEqual(1000, rateRequest.get('coverageInterval'), 'Coverage interval is equal to interval value from rate comparison interval table');
        Assert.areEqual(0, rateRequest.get('tobaccoUse'), 'Tobaco use is 0 since we indicated tabaco use \'no\' on related opportunity');
        Assert.areEqual(1, rateRequest.get('gender'), 'Gender is 1 since we indicated gender \'Male\' on related opportunity');
        Assert.areEqual('WI', rateRequest.get('residentState'), 'Resident state matches mailing state related person account');
        Assert.areEqual('44', rateRequest.get('issueAge'), 'Issue Age matches age on related person account');
        Assert.areEqual('1979-09-07', rateRequest.get('birthDate'), 'Birth date matches birth date related person account');
        Assert.areEqual('11111111', rateRequest.get('contractNumber'), 'Contract number matches contract number related affiliation account');
        Test.stopTest();
    }
}