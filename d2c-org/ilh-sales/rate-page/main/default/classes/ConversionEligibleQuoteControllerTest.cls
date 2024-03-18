/**
 * Copyright: TruStage
 * Purpose: Unit tests for ConversionEligibleQuoteController class
 */
@isTest
private class ConversionEligibleQuoteControllerTest {

    @isTest
    public static void checkEligibilityTest() {
          // Creating a successful mock response
          staticResourceCalloutMock mock = new staticResourceCalloutMock();
          mock.setStaticResource('mock_ConversionEligibleQuoteResponse');
          mock.setStatusCode(200);
          mock.setHeader('Content-Type', 'application/json');
          Test.setMock(HttpCalloutMock.class, mock);
  
          // Creating initial search criteria for request
          Map<String, Object> quoteRequest = new Map<String, Object>();
          quoteRequest.put('isTermBeingKept', false);
          Test.startTest();
          List<ConversionEligibleQuoteWrapper> wrapper = ConversionEligibleQuoteController.checkEligibility(quoteRequest);
          // Verifying search results
          System.assert(wrapper.size() > 0, 'Expecting more than 1 result');
  
          Test.stopTest();
      }
  
      @isTest
      public static void getRatesTest() {
          // Creating a successful mock response
          staticResourceCalloutMock mock = new staticResourceCalloutMock();
          mock.setStaticResource('mock_ConversionEligibleQuoteResponse');
          mock.setStatusCode(200);
          mock.setHeader('Content-Type', 'application/json');
          Test.setMock(HttpCalloutMock.class, mock);
  
          // Creating initial search criteria for request
          Map<String, Object> quoteRequest = new Map<String, Object>{
              'conversionProductCode' => '2022 Whole Life Conversion',
              'currentTermPolicyNumber' => 'LC0168889',
              'currentTermCompanyCode' => '51',
              'channel' => 'TELEM',
              'insuredResidentState' => 'PA',
              'conversionCoverageAmount' => 25000,
              'isTermBeingKept' => false
          };
  
          Test.startTest();
          List<EligibleProductRateWrapper> wrapper = ConversionEligibleQuoteController.getRates(quoteRequest);
          // Verifying search results
          System.assert(wrapper.size() > 0, 'Expecting more than 1 result');
  
          Test.stopTest();
    }
}