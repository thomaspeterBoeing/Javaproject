/**
 * Copyright: TruStage
 * Purpose: Unit tests for EligibleProductRateWrapper class
 */
@isTest
public class EligibleProductRateWrapperTests {

    @isTest
    private static void buildGridTest() {
        EligibleProductQuoteResult ipd1 = new EligibleProductQuoteResult();
        ipd1.productName = 'Product1';
        ipd1.productCode = 'Product 1';
        ipd1.productCategory = 'Simplified Issue WL';

        EligibleProductQuoteResult.CoverageOption co1 = new EligibleProductQuoteResult.CoverageOption();
        co1.coverage = 1000;
        co1.premium = 1.00;
        co1.frequency = 'Annual';

        EligibleProductQuoteResult.CoverageOption co2 = new EligibleProductQuoteResult.CoverageOption();
        co2.coverage = 1000;
        co2.premium = 2.00;
        co2.frequency = 'Monthly';

        EligibleProductQuoteResult.CoverageOption co3 = new EligibleProductQuoteResult.CoverageOption();
        co3.coverage = 1000;
        co3.premium = 3.00;
        co3.frequency = 'Quarterly';

        EligibleProductQuoteResult.CoverageOption co4 = new EligibleProductQuoteResult.CoverageOption();
        co4.coverage = 1000;
        co4.premium = 4.00;
        co4.frequency = 'Semiannual';

        ipd1.coverages = new List<EligibleProductQuoteResult.CoverageOption>{co1, co2, co3, co4};
        List<EligibleProductQuoteResult> results = new List<EligibleProductQuoteResult>{ipd1};

        Test.startTest();
        EligibleProductRateWrapper defaultConstructor = new EligibleProductRateWrapper();//Calling default constructor
        EligibleProductRateWrapper result = new EligibleProductRateWrapper(results);
        Assert.areEqual(1, result.eligibleRates.size(), 'One result returned');
        Assert.areEqual('1000', result.eligibleRates[0].coverage, 'Coverage is 1000');
        
        EligibleProductRateWrapper.EligibleRateCell product1Cell = result.eligibleRates[0].productinfo.get('Product1');
        Assert.isNotNull(product1Cell, 'Product 1 is in results');
        Assert.areEqual('Product 1', product1Cell.productcode, 'Product code is Product 1');
        Assert.areEqual(1000, product1Cell.coverage, 'Product 1 coverage is 1000');
        Assert.areEqual(1.00, product1Cell.annual, 'Product 1 Annual premium is 1.00');
        Assert.areEqual(2.00, product1Cell.monthly, 'Product 1 Monthly premium is 2.00');
        Assert.areEqual(3.00, product1Cell.quarterly, 'Product 1 Quarterly premium is 3.00');
        Assert.areEqual(4.00, product1Cell.semiannual, 'Product 1 Semiannual premium is 4.00');
        Assert.areEqual('Product 1', product1Cell.productcode, 'Product code is Product 1');
    }
}