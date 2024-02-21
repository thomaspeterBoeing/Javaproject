/***
Copyright: TruStage
Purpose: Service class that get eligible product quotes
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public with sharing class EligibleRateService {
    /**
     * Purpose: This method get eligible rates from ILHProductQuoteService
     * @param rateRequest : Request to send to ILHProductQuoteService
     * @return : Instance or EligibleProductRateWrapper class
     */
    public EligibleProductRateWrapper getRates(Map<String, Object> requestMap) {
        try {
            Map<String, Object> rateRequest = getQuoteRequestMap(requestMap);

            List<EligibleProductQuoteResult> rates = EligibleProductQuoteResult.parse(new ILHProductQuoteService().getAvailableProducts(rateRequest));
            EligibleProductRateWrapper wrapper = new EligibleProductRateWrapper(rates);
            return wrapper;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting rates', 'EligibleRateService.cls', null, 'getRates', null, null, null);
        }
        return null;
    }

    private Map<String, Object> getQuoteRequestMap(Map<String, Object> requestMap) {
        String frequency = (String)requestMap.get('frequency');
        String billingMethodCode = (String)requestMap.get('billingMethodCode');
        String productCategory = (String)requestMap.get('productCategory');
        Id oppId = (Id)requestMap.get('oppId');
        integer maxCov;
        integer minCov;
        integer covInterval;
        string billMethod;

        if(productCategory == 'Life'){
            maxCov = 300000;
            minCov = 1000;
            covInterval = 1000;
        } else if (productCategory == 'ADD'){
            maxCov = 500000;
            minCov = 5000;
            covInterval = 5000;
        }

        Map<String, Object> quoteRequestMap = new Map<String, Object> {
            'channel' => 'Telem',
            'maxCoverage' => maxCov,
            'minCoverage' => minCov,
            'coverageInterval' => covInterval,
            'organizationId' => '',
            'requestingSystemName' => 'sforcecs'
        };

        Opportunity opp = [SELECT TobaccoUse__c, Affiliation__r.ContractNumberUnformatted__c, Account.PersonBirthdate, Account.Age__pc, Account.Gender__pc, 
                            Account.PersonMailingState FROM Opportunity WHERE id =: oppId WITH USER_MODE];
        quoteRequestMap.put('tobaccoUse',opp?.TobaccoUse__c != null ? (opp.TobaccoUse__c == 'No' ? 0 : 1) : null);
        quoteRequestMap.put('gender', opp?.Account?.Gender__pc != null ? (opp.Account.Gender__pc == 'Male' ? 1 : 0) : null);
        quoteRequestMap.put('residentState', opp?.Account?.PersonMailingState != null ? opp.Account.PersonMailingState : '');
        quoteRequestMap.put('issueAge', opp?.Account?.Age__pc != null ? String.valueOf(opp.Account.Age__pc) : '');
        quoteRequestMap.put('contractNumber', opp?.Affiliation__r?.ContractNumberUnformatted__c != null ? opp.Affiliation__r.ContractNumberUnformatted__c : '');
        quoteRequestMap.put('birthDate', opp?.Account?.PersonBirthdate != null ? String.valueOf(opp.Account.PersonBirthdate) : '');
        quoteRequestMap.put('frequency',frequency);  
        quoteRequestMap.put('billingMethod',billingMethodCode);
        quoteRequestMap.put('asOfDate', Date.today());

        system.debug('Request Map = ' + quoteRequestMap);
        return quoteRequestMap;
    }
}