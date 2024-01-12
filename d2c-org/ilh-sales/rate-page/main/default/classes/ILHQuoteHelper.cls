/***
Copyright: TruStage
Purpose: Helper class for quote object
1.0 - Adam Perschke-Ely   - 1/12/2024  - Created for new D2C Salesfore instance.
***/
public with sharing class ILHQuoteHelper {
     /**
     * Purpose: This method gets quotes related to the given opportunity id
     * @param oppId : Opportunity id to get related quotes
     */
    public List<ResultsWrapper> getQuotes(String oppId) {
        List<Quote> quotes = new List<Quote>();
        List<ResultsWrapper> results = new List<ResultsWrapper>();

        try {
            //Query all quotes related to opportunity
            quotes = [SELECT id, Product__r.Name, Product__r.ProductCode, CoverageAmount__c, Premium__c, Status FROM Quote WHERE OpportunityId =: oppId];

            //Assigning quote values to wrapper instances
            for (Quote q : quotes) {
                ResultsWrapper newWrap = new ResultsWrapper();
                newWrap.quoteId = q.id;
                newWrap.coverage = q?.CoverageAmount__c;
                newWrap.cost = q?.Premium__c;
                newWrap.productName = q?.Product__r?.Name;
                newWrap.productCode = q?.Product__r?.ProductCode;
                newWrap.decision = q?.Status;
                results.add(newWrap);
            }
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting quotes in cart', 'ILHQuoteHelper.cls', oppId, 'getQuotes', null, null, null);
        }
        return results;
    }

    /**
     * Purpose: This method inserts a new quote record on the give opportunity id
     * @param payload : Contains field information to be inserted
     */
    public void insertQuote(Map<String, Object> payload) {
        try {
            Quote newQuote = new Quote();
            newQuote = payloadToQuote(payload, true);//Create new quote object for insert
            insert newQuote;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while adding quote to cart', 'ILHQuoteHelper.cls', null, 'insertQuote', null, null, null);
        }
    }

    /**
     * Purpose: This method updates a quote record
     * @param payload : Contains field information to be updated
     */
    public void updateQuote(Map<String, Object> payload) {
        try {
            Quote newQuote = new Quote();
            newQuote = payloadToQuote(payload, false);//Create new quote object for update
            update newQuote;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while updating quote', 'ILHQuoteHelper.cls', null, 'updateQuote', null, null, null);
        }
    }

    /**
     * Purpose: This method deletes quote for a given id
     * @param quoteId : Id of quote to delete
     */
    public void deleteQuote(String quoteId) {
        try {
            delete [SELECT id FROM Quote WHERE id =: quoteId];  
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while removing quote from cart', 'ILHQuoteHelper.cls', quoteId, 'deleteQuote', null, null, null);
        }
    }

    /**
     * Purpose: This method transforms payload into a quote object
     * @param payload : Payload to transform into a quote object
     * @return : New quote object
     */
    private Quote payloadToQuote(Map<String, Object> payload, Boolean isInsert) {
        Quote newQuote = new Quote();
        Opportunity opp = new Opportunity();
        List<Product2> selectedProduct = new List<Product2>();
        Boolean selectedProductFound = false;

        //Get values from map
        String quoteId = (String)payload.get('quoteId');
        String costStr = (String)payload.get('cost');
        String coverageStr = (String)payload.get('coverage');
        String productName = (String)payload.get('productName');
        String productCode = (String)payload.get('productCode');
        String oppId = (String)payload.get('oppId');
        String decision = (String)payload.get('decision');

        //Convert map string values integer or decimal values
        Decimal cost = costStr != null ? Decimal.valueOf(costStr) : 0;
        Integer coverage = coverageStr != null ? Integer.valueOf(coverageStr) : 0;

        //Don't map if don't have an opportunity id from rate page
        if (String.isNotEmpty(oppId)) {
            Date todaysDate = Date.today();
            opp = [SELECT Affiliation__c, Account.Age__pc, Account.PersonBirthdate, Account.Gender__pc, HealthAssessment__c, InsurancePurpose__c, 
                    TobaccoUse__c, Account.PersonMailingState, Account.LastName, Account.PersonHomePhone, Account.PersonEmail, Account.ShippingCity,
                    Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet FROM Opportunity WHERE id =: oppId];
        }

        //Only map opportunity/account fields on insert only
        if (isInsert) {
            //Find product id based on product code from cart item
            if (String.isNotEmpty(productCode)) {
                selectedProduct = [SELECT id, Name FROM Product2 WHERE ProductCode =: productCode AND IsActive =: true];

                if (selectedProduct != null && !selectedProduct.isEmpty()) {
                    selectedProductFound = true;
                    newQuote.Product__c = selectedProduct[0].id;
                }
            }

            //Don't map if don't have an opportunity id from rate page
            if (opp != null) {
                Date todaysDate = Date.today();
                newQuote.OpportunityId = oppId;
                newQuote.Affiliation__c = opp.Affiliation__c;
                newQuote.Age__c = opp.Account?.Age__pc;
                newQuote.Birthdate__c = opp.Account?.PersonBirthdate;
                newQuote.Gender__c = opp.Account?.Gender__pc;
                newQuote.HealthAssessment__c = opp.HealthAssessment__c;
                newQuote.InsurancePurpose__c = opp.InsurancePurpose__c;
                newQuote.TobaccoUse__c = opp.TobaccoUse__c;
                newQuote.ResidentState__c = opp.Account?.PersonMailingState;
                newQuote.Name = opp.Account?.LastName + '-' + Datetime.now() + '-' + (selectedProductFound ? selectedProduct[0].Name : '');
                newQuote.Phone = opp.Account?.PersonHomePhone;
                newQuote.ShippingCity = opp.Account?.ShippingCity;
                newQuote.ShippingCountry = opp.Account?.ShippingCountry;
                newQuote.ShippingPostalCode	= opp.Account?.ShippingPostalCode;
                newQuote.ShippingState = opp.Account?.ShippingState;
                newQuote.ShippingStreet = opp.Account?.ShippingStreet;
                newQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('ILH Sales Quote').getRecordTypeId();
                //newQuote.GrandTotal = TBD;
                //newQuote.ExpirationDate = TBD;
                //newQuote.QuoteRider__c = TBD;
            }

            //Map reamaining quote fields on insert
            newQuote.CoverageAmount__c = coverage;
            newQuote.Premium__c = cost;
        }

        if (String.isNotEmpty(decision)) {
            List<Quote> existingQuote = new List<Quote>();

            //Find if quote exists
            if (String.isNotEmpty(quoteId)) {
                existingQuote = [SELECT Status, Email FROM Quote WHERE id =: quoteId LIMIT 1];
            }

            //Only update request date if status is not paper kit or blank value
            if (decision.equalsIgnoreCase('Paper Kit') && (existingQuote == null || existingQuote.isEmpty() || existingQuote[0]?.Status == null ||
                !existingQuote[0]?.Status.equalsIgnoreCase('Paper Kit'))) {
                newQuote.PaperKitRequestDate__c = Date.today();
            }

            //Map email if decision is Email Summary and person account email is not blank
            if (decision.equalsIgnoreCase('Email Summary') && String.isNotEmpty(opp.Account?.PersonEmail) && 
                (existingQuote == null || existingQuote.isEmpty() || (existingQuote != null && !existingQuote.isEmpty() && String.isEmpty(existingQuote[0]?.Email)))) {
                newQuote.Email = opp.Account?.PersonEmail;
            }
        }

        //Map quote id if available
        if (String.isNotEmpty(quoteId)) {
            newQuote.id = quoteId;
        }

        //Decision gets mapped on update and insert
        newQuote.Status = decision;
        return newQuote;
    }

    /**
     * Purpose: Inner wrapper class for results
     * TODO: This will need to be to a different class
     */
    public class ResultsWrapper {
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String oppId;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public Decimal coverage;
        @AuraEnabled
        public Decimal cost;
        @AuraEnabled
        public String decision;
    }
}