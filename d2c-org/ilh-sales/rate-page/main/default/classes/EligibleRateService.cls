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
    public EligibleProductRateWrapper getRates(Id oppId) {
        try {
            Map<String, Object> rateRequest = getRequestMap(oppId);

            List<EligibleProductQuoteResult> rates = EligibleProductQuoteResult.parse(new ILHProductQuoteService().getAvailableProducts(rateRequest));
            EligibleProductRateWrapper wrapper = new EligibleProductRateWrapper(rates);
            return wrapper;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting rates', 'EligibleRateService.cls', null, 'getRates', null, null, null);
        }
        return null;
    }

    private Map<String, Object> getRequestMap(Id oppId) {
        Map<String, Object> requestMap = new Map<String, Object> {
            'channel' => 'Telem',
            'maxCoverage' => 500000,
            'minCoverage' => 1000,
            'asOfDate' => '2023-11-21',
            'coverageInterval' => 1000,
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
        return requestMap;
    }
}