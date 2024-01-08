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
            Name = 'TestProd'
        );
        insert newProduct;  
    }

    @isTest
    static void getQuotesTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Test.startTest();
        List<ILHCartController.ResultsWrapper> results = ILHCartController.getQuotes(oppId);
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
        List<Quote> quotes = new List<Quote>();
        quotes = [SELECT id FROM Quote WHERE OpportunityId =: oppId];
        Assert.areEqual(2, quotes.size());

        try {
            payload = new Map<String, Object>();
            payload.put('oppId', '1');
            ILHCartController.insertQuote(payload);
            Assert.fail();
        } catch (Exception ex) {}
    }

    @isTest
    static void updateQuoteTest() {
        Quote q = [SELECT id, OpportunityId FROM Quote WHERE Name =: 'Test' LIMIT 1];
        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('quoteId', q.id);
        payload.put('oppId', q.OpportunityId);
        payload.put('decision', 'Application');
        ILHCartController.updateQuote(payload);
        Quote updatedQuote = [SELECT id, Status FROM Quote WHERE id =: q.id];
        Assert.areEqual(q.id, updatedQuote.id);
        Assert.areEqual('Application', updatedQuote.Status);

        try {
            payload = new Map<String, Object>();
            payload.put('quoteId', null);
            ILHCartController.updateQuote(payload);
            Assert.fail();
        } catch (Exception ex) {}
    }

    @isTest
    static void deleteQuoteTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Id quoteId = [SELECT id FROM Quote WHERE OpportunityId =: oppId LIMIT 1].id;
        Test.startTest();
        ILHCartController.deleteQuote(quoteId);
        List<Quote> quotes = new List<Quote>();
        quotes = [SELECT id FROM Quote WHERE OpportunityId =: oppId];
        Assert.areEqual(0, quotes.size());
    }

    @isTest
    static void checkoutTest() {
        ILHCartController.checkout();
    }
}