/**
 * Copyright: TruStage
 * Purpose: Unit tests for ConversionEligibleQuoteRequest class
 */
@isTest
public class ConversionEligibleQuoteRequestTest {
    @isTest
    static void testConversionEligibleQuoteRequest() {
        // Create a new instance of ConversionEligibleQuoteRequest
        ConversionEligibleQuoteRequest request = new ConversionEligibleQuoteRequest();

        // Set values for the properties
        request.conversionProductCode = 'TestProductCode';
        request.currentTermPolicyNumber = 'TestPolicyNumber';
        request.currentTermCompanyCode = 'TestCompanyCode';
        request.channel = 'TestChannel';
        request.insuredResidentState = 'TestState';
        request.conversionCoverageAmount = 10000;
        request.isTermBeingKept = false;

        // Verify that the properties have been set correctly
        System.assertEquals('TestProductCode', request.conversionProductCode,'Product Code was not set');
        System.assertEquals('TestPolicyNumber', request.currentTermPolicyNumber,'Policu number was not set');
        System.assertEquals('TestCompanyCode', request.currentTermCompanyCode,'Company Code was not set');
        System.assertEquals('TestState', request.insuredResidentState,'insuredResidentState was not set');
        System.assertEquals(10000, request.conversionCoverageAmount,'conversionCoverageAmount was not set');
        System.assertEquals(false, request.isTermBeingKept,'isTermBeingKept was not set');
    }
}
