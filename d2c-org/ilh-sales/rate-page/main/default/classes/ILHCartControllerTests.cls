/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ILHCartController class
 */
@isTest
private class ILHCartControllerTests {

    @testSetup static void setup() {
        Opportunity newOpp = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Quote',
            HealthAssessment__c = 'No Health Issues',
            InsurancePurpose__c = 'Gift',
            TobaccoUse__c = 'No',
            ProposedCoverage__c = 20000,
            CloseDate = Date.today()
        );
        insert newOpp;

        Quote newQuote = new Quote(
            OpportunityId = newOpp.id,
            Name = 'Test'
        );
        insert newQuote;  

        Product2 newProduct = new Product2(
            ProductCode = 'TestProd',
            Name = 'TestProd',
            IsActive = true
        );
        insert newProduct;  
    }

    @isTest
    static void getQuotesTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Test.startTest();
        List<ILHQuoteHelper.ResultsWrapper> results = ILHCartController.getQuotes(oppId);
        Assert.areEqual(1, results.size());
    }

    @isTest
    static void insertQuoteTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('oppId', oppId);
        payload.put('productCode', 'TestProd');
        ILHCartController.insertQuote(payload);
    }

    @isTest
    static void updateQuoteTest() {
        Quote q = [SELECT id, OpportunityId FROM Quote WHERE Name =: 'Test' LIMIT 1];
        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('quoteId', q.id);
        payload.put('oppId', q.OpportunityId);
        payload.put('decision', 'Application');
        List<Map<String, Object>> quotes = new List<Map<String, Object>>{payload};
        ILHCartController.updateQuotes(quotes);
    }

    @isTest
    static void deleteQuoteTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Id quoteId = [SELECT id FROM Quote WHERE OpportunityId =: oppId LIMIT 1].id;
        Test.startTest();
        ILHCartController.deleteQuote(quoteId);
    }

    @isTest
    static void checkoutTest() {
        ILHCartController.checkout();
    }
}