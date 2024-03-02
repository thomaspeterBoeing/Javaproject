/**********************************************************************************
 * Copyright: TruStage
 * Title:  ILHConversionEligibleQuoteServiceTest
 * Date:   Jan 2024
 * 
 * Description:  Test Class for all ConversionEligibleQuote* /ILHConversionEligibleQuote* Classes
 * 
 *************************************************************************************/

@isTest
public with sharing class ILHConversionEligibleQuoteServiceTest {
    @isTest
    public static void getQuoteResponseTest() {
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
        List<ConversionEligibleQuoteWrapper> wrapper = (new ILHConversionEligibleQuoteService()).checkEligibility(quoteRequest);
        // Verifying search results
        System.assert(wrapper.size() > 0, 'Expecting more than 1 result');

        Test.stopTest();
    }

    @isTest
    public static void testHandleNonSuccessfulResponse() {
        // Create a scenario where HTTP response status code is greater than 200
        staticResourceCalloutMock mockResponse = new staticResourceCalloutMock();
        mockResponse.setStaticResource('mock_ConversionEligibleQuoteResponse');
        mockResponse.setStatusCode(500);
        mockResponse.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mockResponse);

        // Create a valid ConversionEligibleQuoteRequest
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
        List<ConversionEligibleQuoteWrapper> results = (new ILHConversionEligibleQuoteService()).checkEligibility(quoteRequest);

        // Assert the expected behavior
        System.assertEquals(0, results.size(), 'The result list should be empty for non-successful response.');
        
        Test.stopTest();
    }
}
