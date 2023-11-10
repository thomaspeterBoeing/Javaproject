/***
Copyright: TruStage
Purpose: Lightning Web Component controller Apex supporting logic for marketing history.
1.0 - Rick Baker   - 8/3/2023  - Created for new D2C Salesfore instance.
***/
public class MarketingHistoryController {
    /***
     * Performs a search for contact marketing history by person Id.
     * @param kvpSearchCriteria  -- The search criteria in the format of a key-value-pair mapping
     * @return Returns an array of ILHMarketingHistoryResultsWrapper class instances.
     */
    @AuraEnabled
    public static List<ILHMarketingHistoryResultsWrapper> getMarketHistory(Map<String, Object> kvpSearchCriteria) {
        return (new ILHMarketingHistoryService()).getMarketHistory(kvpSearchCriteria);
    }
}