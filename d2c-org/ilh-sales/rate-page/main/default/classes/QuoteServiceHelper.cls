/***
Copyright: TruStage
Purpose: Service class that get eligible product quotes
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public with sharing class QuoteServiceHelper {
    private Map<String, Object> quoteRequestMap;
    private Id oppId;
    /**
     * Purpose: This method get eligible rates from ILHProductQuoteService
     * @param rateRequest : Request to send to ILHProductQuoteService
     * @return : Instance or EligibleProductRateWrapper class
     */
    public EligibleProductRateWrapper getRates(Map<String, Object> requestMap) {
        try {
            String productCategory = (String)requestMap.get('productCategory');
            Map<String, Object> rateRequest = getQuoteRequestMap(requestMap);

            List<EligibleProductQuoteResult> rates = EligibleProductQuoteResult.parse(new ILHProductQuoteService().getAvailableProducts(rateRequest), productCategory);
            EligibleProductRateWrapper wrapper = new EligibleProductRateWrapper(rates);
            return wrapper;
        } catch (Exception ex) {
            new ErrorLogger(ex, ex.getMessage(), 'QuoteServiceHelper.cls', null, 'getRates', null, null, null);
        }
        return null;
    }

    /**
     * Purpose: Creates request map for quote service
     * @param requestMap Request from rate page
     * @return New request map to send to quote service
     */
    @TestVisible 
    private Map<String, Object> getQuoteRequestMap(Map<String, Object> requestMap) {
        string billMethod;

        String frequency = (String)requestMap.get('frequency');
        String billingMethodCode = (String)requestMap.get('billingMethodCode');
        String productCategory = (String)requestMap.get('productCategory');
        oppId = (Id)requestMap.get('oppId');

        RateComparisonInterval__mdt rci = ILHUtilities.getRateComparisonInterval(productCategory);

        quoteRequestMap = new Map<String, Object> {
            'channel' => 'Telem',
            'maxCoverage' => rci.UpperBound__c,
            'minCoverage' => rci.LowerBound__c,
            'coverageInterval' => rci.Interval__c,
            'organizationId' => '',
            'requestingSystemName' => 'sforcecs',
            'asOfDate' => Date.today()
        };

        if (String.isNotBlank(frequency) && String.isNotBlank(billingMethodCode)) {//Billing Method and frequency need to have values in order to send in request
            quoteRequestMap.put('frequency',frequency);  

            if (billingMethodCode.equalsIgnoreCase('ACH/PAC')) {//Consumer Eligible Quote service doesn't accept ACH/PAC
                billingMethodCode = 'ACH';
            }
            quoteRequestMap.put('billingMethod',billingMethodCode);
        }
        mapOpportunityInformation();
        return quoteRequestMap;
    }

    /**
     * Purpose: Maps opportunity information to quote request map
     * @param quoteRequestMap Pass-by-value parameter
     * @param oppId Id of opportunity to query on
     */
    private void mapOpportunityInformation() {
        Opportunity opp = [SELECT TobaccoUse__c, Affiliation__r.ContractNumberUnformatted__c, Account.PersonBirthdate, Account.Age__pc, Account.Gender__pc, 
                            Account.PersonMailingState FROM Opportunity WHERE id =: oppId WITH USER_MODE];
        quoteRequestMap.put('tobaccoUse',opp?.TobaccoUse__c != null ? (opp.TobaccoUse__c == 'No' ? 0 : 1) : null);
        quoteRequestMap.put('gender', opp?.Account?.Gender__pc != null ? (opp.Account.Gender__pc == 'Male' ? 1 : 0) : null);
        quoteRequestMap.put('residentState', opp?.Account?.PersonMailingState != null ? opp.Account.PersonMailingState : '');
        quoteRequestMap.put('issueAge', opp?.Account?.Age__pc != null ? String.valueOf(opp.Account.Age__pc) : '');
        quoteRequestMap.put('contractNumber', opp?.Affiliation__r?.ContractNumberUnformatted__c != null ? opp.Affiliation__r.ContractNumberUnformatted__c : '');
        quoteRequestMap.put('birthDate', opp?.Account?.PersonBirthdate != null ? String.valueOf(opp.Account.PersonBirthdate) : '');
    }
}