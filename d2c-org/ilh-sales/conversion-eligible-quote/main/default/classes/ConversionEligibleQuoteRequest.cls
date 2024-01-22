/**********************************************************************************
 * Title:  ConversionEligibleQuoteRequest
 * Date:   Jan 2024
 * 
 * Description:  Request class for the ConversionEligibleQuote endpoint  
 * 
 *************************************************************************************/

public class ConversionEligibleQuoteRequest {
    public String conversionProductCode {get;set;}
    public String currentTermPolicyNumber {get;set;}
    public String currentTermCompanyCode {get;set;}
    public String channel {get;set;}
    public String insuredResidentState {get;set;}
    public Integer conversionCoverageAmount {get;set;}
    public Boolean isTermBeingKept {get;set;}
}