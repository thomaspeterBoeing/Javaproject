/**
 * Copyright: TruStage
 * Purpose: Unit tests for the EligibleRateService class
 */
@isTest
private class EligibleRateServiceTests {

    @isTest
    static void getRatesTest() {
        //Creating a mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockProductQuoteResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        EligibleProductRateWrapper result = new EligibleRateService().getRates(null);
        Assert.isNotNull(result, 'Result is not null');
    }
}