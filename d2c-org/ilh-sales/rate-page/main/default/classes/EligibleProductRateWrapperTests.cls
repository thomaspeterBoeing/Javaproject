/**
 * Copyright: TruStage
 * Purpose: Unit tests for EligibleProductRateWrapper class
 */
@isTest
public class EligibleProductRateWrapperTests {

    @testSetup
    static void setup() {
        Product2 p1 = new Product2(
            Name = 'Product1',
            ProductCode = 'Product 1',
            IsActive = true
        );
        insert p1;
    }

    @isTest
    private static void buildGridTest() {
        EligibleProductQuoteResult ipd1 = new EligibleProductQuoteResult();
        ipd1.productCode = 'Product 1';

        EligibleProductQuoteResult.CoverageOption co1 = new EligibleProductQuoteResult.CoverageOption();
        co1.coverage = 1000;
        co1.annual = 1.00;
        co1.monthly = 2.00;
        co1.quarterly = 3.00;
        co1.semiannual = 4.00;

        EligibleProductQuoteResult.CoverageOption co2 = new EligibleProductQuoteResult.CoverageOption();
        co2.coverage = 2000;
        co2.annual = 2.00;
        co2.monthly = 4.00;
        co2.quarterly = 5.00;
        co2.semiannual = 6.00;

        ipd1.coverages = new List<EligibleProductQuoteResult.CoverageOption>{co1, co2};

        EligibleProductQuoteResult.BillingOption bo1 = new EligibleProductQuoteResult.BillingOption();
        bo1.billingMethod = 'ACH';
        bo1.effectiveDate = '01/01/2024';

        EligibleProductQuoteResult.BillingOption bo2 = new EligibleProductQuoteResult.BillingOption();
        bo2.billingMethod = 'Credit Card';
        bo2.effectiveDate = null;

        EligibleProductQuoteResult.BillingOption bo3 = new EligibleProductQuoteResult.BillingOption();
        bo3.billingMethod = 'Credit Card';
        bo3.effectiveDate = '01/01/2024';

        EligibleProductQuoteResult.BillingOption bo4 = new EligibleProductQuoteResult.BillingOption();
        bo4.billingMethod = 'ACH';
        bo4.effectiveDate = '01/01/2024';

        ipd1.billingOptions = new List<EligibleProductQuoteResult.BillingOption>{bo1, bo2, bo3, bo4};

        List<EligibleProductQuoteResult> results = new List<EligibleProductQuoteResult>{ipd1};

        Test.startTest();
        EligibleProductRateWrapper result = new EligibleProductRateWrapper(results);
        Assert.areEqual(2, result.eligibleRates.size(), 'Two rows returned');
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

        Assert.areEqual('ACH', result.eligibleBillingOptions.iterator().next().billingMethod, 'First eligible billing option method is ACH');
        Assert.areEqual('01/01/2024', result.eligibleBillingOptions.iterator().next().effectiveDate, 'First eligible billing option effective date is 01/01/2024');
        Test.stopTest();
    }

    @isTest
    private static void equalsHashCodeTest() {
        EligibleProductRateWrapper.EligibleBillingOption ebo1 = new EligibleProductRateWrapper.EligibleBillingOption();
        ebo1.billingMethod = 'ACH';
        ebo1.effectiveDate = '01/01/2024';

        EligibleProductRateWrapper.EligibleBillingOption ebo2 = new EligibleProductRateWrapper.EligibleBillingOption();
        ebo2.billingMethod = 'Credit Card';
        ebo2.effectiveDate = null;

        EligibleProductRateWrapper.EligibleBillingOption ebo3 = new EligibleProductRateWrapper.EligibleBillingOption();
        ebo3.billingMethod = 'Credit Card';
        ebo3.effectiveDate = '01/01/2024';

        EligibleProductRateWrapper.EligibleBillingOption ebo4 = new EligibleProductRateWrapper.EligibleBillingOption();
        ebo4.billingMethod = 'ACH';
        ebo4.effectiveDate = '01/01/2024';

        Test.startTest();
        Assert.areNotEqual(ebo1.hashCode(), ebo2.hashCode(), 'Hashcodes mismatch');
        Assert.areNotEqual(ebo2.hashCode(), ebo3.hashCode(), 'Hashcodes mismatch');
        Assert.areEqual(ebo4.hashCode(), ebo1.hashCode(), 'Hashcodes match');

        Assert.isFalse(ebo1.equals(ebo2), 'Billing methods are not equal');
        Assert.isFalse(ebo2.equals(ebo3), 'Billing methods are the same, but effective date for first row is blank.');
        Assert.isTrue(ebo4.equals(ebo1), 'Billing methods are the same');
        Test.stopTest();
    }
}