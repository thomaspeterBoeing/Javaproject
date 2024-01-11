@isTest
public class ILHProductQuoteServiceTests {
    @isTest
    private static void getRatesTest() {
        //Creating a mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockProductQuoteResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        RateQuoteDataGrid result = new ILHProductQuoteService().getRates(null);
        Assert.isNotNull(result, 'We have at least one result');
    }

    @isTest
    private static void getProductsTest() {
        //Creating a mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockProductQuoteResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<EligibleProduct> results = new ILHProductQuoteService().getProducts(null);
        Assert.isNotNull(results);
        Assert.isTrue(results.size() > 0);
    }
}