/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ILHQuoteHelper class
 */
@isTest
private class ILHQuoteHelperTests {

    @testSetup static void setup() {
        Account personAccount = new Account (
            PersonBirthdate = Date.today(),
            FirstName = 'Test',
            LastName = 'Test',
            Gender__pc = 'Male',
            PersonMailingState = 'WI',
            PersonHomePhone = '1111111111',
            ShippingCity = 'Madison',
            ShippingCountry = 'US',
            ShippingPostalCode = '11111',
            ShippingState = 'WI',
            ShippingStreet = '123 Main Street',
            PersonEmail = 'test@test.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert personAccount;

        Account affiliation = new Account (
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliation').getRecordTypeId()
        );
        insert affiliation;

        Opportunity newOpp = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Quote',
            CloseDate = Date.today(),
            Affiliation__c = affiliation.id,
            AccountId = personAccount.id,
            HealthAssessment__c = 'No Health Issues',
            InsurancePurpose__c = 'Final Expenses',
            TobaccoUse__c = 'No'
        );
        insert newOpp;

        Product2 newProduct = new Product2(
            ProductCode = 'TestProd',
            Name = 'TestProd',
            IsActive = true
        );
        insert newProduct;  
    }

    @isTest
    static void getQuotesTest() {
        ILHQuoteHelper helper = new ILHQuoteHelper();
        Map<String, Object> payload = new Map<String, Object>();

        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;
        payload.put('oppId', oppId);
        payload.put('productCode', 'TestProd');
        helper.insertQuote(payload);
        Test.startTest();
        List<ILHQuoteHelper.ResultsWrapper> results = helper.getQuotes(oppId);
        Assert.areEqual(1, results.size());
    }

    @isTest
    static void insertUpdateQuoteTest() {
        ILHQuoteHelper helper = new ILHQuoteHelper();
        Product2 product = [SELECT id FROM Product2 WHERE ProductCode =: 'TestProd'];
        Opportunity opp = [SELECT id, AccountId, Affiliation__c, HealthAssessment__c, InsurancePurpose__c, TobaccoUse__c, Account.Age__pc, Account.PersonBirthdate, 
                            Account.Gender__pc, Account.PersonMailingState, Account.PersonHomePhone, Account.ShippingCity, Account.ShippingCountry, 
                            Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet, Account.PersonEmail FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1];
        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('oppId', opp.id);
        payload.put('cost', '4.50');
        payload.put('coverage', '3000');
        payload.put('productCode', 'TestProd');
        payload.put('decision', 'Email Summary');
        payload.put('paymentFrequency', 'Monthly');
        payload.put('billingMethod', 'ACH');

        helper.insertQuote(payload);
        Quote q = [SELECT id, Affiliation__c, Age__c, Birthdate__c, Gender__c, HealthAssessment__c, InsurancePurpose__c, TobaccoUse__c, ResidentState__c, Phone, ShippingCity,
                    ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Product__c, CoverageAmount__c, Premium__c, Status, Email, BillingMethod__c,  PaymentFrequency__c
                    FROM Quote WHERE OpportunityId =: opp.id];

        Assert.isNotNull(q);
        Assert.areEqual(opp.Affiliation__c, q.Affiliation__c);
        Assert.areEqual(opp.Account.Age__pc, q.Age__c);
        Assert.areEqual(opp.Account.PersonBirthdate, q.Birthdate__c);
        Assert.areEqual(opp.Account.Gender__pc, q.Gender__c);
        Assert.areEqual(opp.HealthAssessment__c, q.HealthAssessment__c);
        Assert.areEqual(opp.InsurancePurpose__c, q.InsurancePurpose__c);
        Assert.areEqual(opp.TobaccoUse__c, q.TobaccoUse__c);
        Assert.areEqual(opp.Account.PersonMailingState, q.ResidentState__c);
        Assert.areEqual(opp.Account.PersonHomePhone, q.Phone);
        Assert.areEqual(opp.Account.ShippingCountry, q.ShippingCountry);
        Assert.areEqual(opp.Account.ShippingPostalCode, q.ShippingPostalCode);
        Assert.areEqual(opp.Account.ShippingState, q.ShippingState);
        Assert.areEqual(opp.Account.ShippingStreet, q.ShippingStreet);
        Assert.areEqual(Integer.valueOf((String)payload.get('coverage')), q.CoverageAmount__c);
        Assert.areEqual(Decimal.valueOf((String)payload.get('cost')), q.Premium__c);
        Assert.areEqual(product.id, q.Product__c);
        Assert.areEqual(opp.Account.PersonEmail, q.Email);
        Assert.areEqual(payload.get('billingMethod'), q.BillingMethod__c);
        Assert.areEqual(payload.get('paymentFrequency'), q.PaymentFrequency__c);

        payload.put('decision', 'Paper Kit');
        payload.put('coverage', '4000');
        payload.put('quoteId', q.id);
        helper.updateQuote(payload);
        q = [SELECT Status, CoverageAmount__c, PaperKitRequestDate__c FROM Quote WHERE OpportunityId =: opp.id];
        Assert.areEqual('Paper Kit', q.Status);
        Assert.areEqual(Date.today(), q.PaperKitRequestDate__c);
        Assert.areEqual(3000, q.CoverageAmount__c, 'Coverage hasn\'t changed');

        //Updating email on person accout
        Account acc = new Account (
            id = opp.AccountId,
            PersonEmail = 'test2@test.com'
        );
        update acc;

        payload.put('decision', 'Email Summary');
        helper.updateQuote(payload);
        q = [SELECT Email FROM Quote WHERE OpportunityId =: opp.id];
        Assert.areEqual(opp.Account.PersonEmail, q.Email, 'Email should be equal to original email, not the updated one');

        try {
            payload = new Map<String, Object>();
            payload.put('oppId', '1');
            helper.insertQuote(payload);
            Assert.fail();
        } catch (Exception ex) {}

        try {
            payload = new Map<String, Object>();
            payload.put('quoteId', '1');
            helper.updateQuote(payload);
            Assert.fail();
        } catch (Exception ex) {}
    }

    @isTest
    static void deleteQuoteTest() {
        ILHQuoteHelper helper = new ILHQuoteHelper();
        Id oppId = [SELECT id FROM Opportunity WHERE Name =: 'TestOpp' LIMIT 1].id;

        Map<String, Object> payload = new Map<String, Object>();
        payload.put('oppId', oppId);
        payload.put('productCode', 'TestProd');
        helper.insertQuote(payload);

        List<ILHQuoteHelper.ResultsWrapper> results = helper.getQuotes(oppId);
        helper.deleteQuote(results[0].quoteId);
        results = helper.getQuotes(oppId);
        Assert.areEqual(0, results.size());
    }
}