/***
Copyright: TruStage
Purpose: Service class that get eligible product quotes
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public class EligibleRateService {
    /**
     * Purpose: This method get eligible rates from ILHProductQuoteService
     * @param rateRequest : Request to send to ILHProductQuoteService
     * @return : Instance or EligibleProductRateWrapper class
     */
    public EligibleProductRateWrapper getRates(Id oppId,String productCategory, String frequency, String billingMethod) {
        try {
            Map<String, Object> rateRequest = getRequestMap(oppId,productCategory,frequency,billingMethod);

            List<EligibleProductQuoteResult> rates = EligibleProductQuoteResult.parse(new ILHProductQuoteService().getAvailableProducts(rateRequest));
            EligibleProductRateWrapper wrapper = new EligibleProductRateWrapper(rates);
            return wrapper;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting rates', 'EligibleRateService.cls', null, 'getRates', null, null, null);
        }
        return null;
    }

    private Map<String, Object> getRequestMap(Id oppId,String productCategory, String frequency,String billingMethodCode) {
        integer maxCov;
        integer minCov;
        integer covInterval;
        string billMethod;

        if(productCategory == 'Life'){
            maxCov = 300000;
            minCov = 1000;
            covInterval = 1000;           
            billMethod = 'ACH';
        } else if (productCategory == 'ADD'){
            maxCov = 500000;
            minCov = 5000;
            covInterval = 5000;
            billMethod = billingMethodCode;
        }

        Map<String, Object> requestMap = new Map<String, Object> {
            'channel' => 'Telem',
            'maxCoverage' => maxCov,
            'minCoverage' => minCov,
            'asOfDate' => '2023-11-21',
            'coverageInterval' => covInterval,
            'organizationId' => '',
            'requestingSystemName' => 'sforcecs'
        };

        Opportunity opp = [SELECT TobaccoUse__c, Affiliation__r.ContractNumberUnformatted__c, Account.PersonBirthdate, Account.Age__pc, Account.Gender__pc, Account.PersonMailingState FROM Opportunity WHERE id =: oppId];
        requestMap.put('tobaccoUse',opp?.TobaccoUse__c != null ? (opp.TobaccoUse__c == 'No' ? 0 : 1) : null);
        requestMap.put('gender', opp?.Account?.Gender__pc != null ? (opp.Account.Gender__pc == 'Male' ? 0 : 1) : null);
        requestMap.put('residentState', opp?.Account?.PersonMailingState != null ? opp.Account.PersonMailingState : '');
        requestMap.put('issueAge', opp?.Account?.Age__pc != null ? String.valueOf(opp.Account.Age__pc) : '');
        requestMap.put('contractNumber', opp?.Affiliation__r?.ContractNumberUnformatted__c != null ? opp.Affiliation__r.ContractNumberUnformatted__c : '');
        requestMap.put('birthDate', opp?.Account?.PersonBirthdate != null ? String.valueOf(opp.Account.PersonBirthdate) : '');
        requestMap.put('frequency',frequency);  
        requestMap.put('billingMethod',billMethod);

        system.debug('Request Map = ' + requestMap);
        return requestMap;
    }
}