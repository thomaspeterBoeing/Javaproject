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
    }

    @isTest
    static void getQuotesTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Test.startTest();
        List<ILHCartController.ResultsWrapper> results = ILHCartController.getQuotes(oppId);
        Assert.areEqual(1, results.size());
        Assert.areEqual('Test0', results[0].productName);
    }

    @isTest
    static void insertQuoteTest() {
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        Test.startTest();
        ILHCartController.insertQuote(oppId);
        List<Quote> quotes = new List<Quote>();
        quotes = [SELECT id FROM Quote WHERE OpportunityId =: oppId];
        Assert.areEqual(2, quotes.size());

        try {
            ILHCartController.insertQuote('1');
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