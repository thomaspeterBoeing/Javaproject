@isTest
private class EligibleProductQuoteResultTests {

    @isTest
    private static void parseTest() {
        ConsumerEligibleQuoteResponse.CoverageOptions co1 = new ConsumerEligibleQuoteResponse.CoverageOptions();
        co1.coverage = 3000;
        co1.frequency = 'Monthly';
        co1.premium = 3.00;
        List<ConsumerEligibleQuoteResponse.CoverageOptions> cos = new List<ConsumerEligibleQuoteResponse.CoverageOptions>{co1};

        ConsumerEligibleQuoteResponse.EligibleBillingOptionsList ebol1 = new ConsumerEligibleQuoteResponse.EligibleBillingOptionsList();
        ebol1.billingMethodCode = 'ACH';
        ebol1.effectiveDate = '01/01/2024';
        List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList> ebol = new List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList>{ebol1};

        ConsumerEligibleQuoteResponse.EligibleBillingOptionsList ebol2 = new ConsumerEligibleQuoteResponse.EligibleBillingOptionsList();
        ebol2.billingMethodCode = 'ACH';
        List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList> ebo2 = new List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList>{ebol2};

        ConsumerEligibleQuoteResponse.LifeInsuranceProductInfo lipi = new ConsumerEligibleQuoteResponse.LifeInsuranceProductInfo();
        lipi.eligibleBillingOptionsList= ebo2;

        ConsumerEligibleQuoteResponse.ADnDInsuranceProductInfo adndipi = new ConsumerEligibleQuoteResponse.ADnDInsuranceProductInfo();
        adndipi.eligibleBillingOptionsList= ebol;

        ConsumerEligibleQuoteResponse.InsuranceProductDetails ipd = new ConsumerEligibleQuoteResponse.InsuranceProductDetails();
        ipd.insuranceProductDisplayName = 'Test Product';
        ipd.returnFlag = true;
        ipd.productCategory = 'ADD';
        ipd.aDnDInsuranceProductInfo = adndipi;

        ConsumerEligibleQuoteResponse.ProductQuotes pq = new ConsumerEligibleQuoteResponse.ProductQuotes();
        pq.productCode = 'Test';
        pq.insuranceProductDetails = ipd;
        pq.coverageOptions = cos;

        ConsumerEligibleQuoteResponse.QuoteResponse qr = new ConsumerEligibleQuoteResponse.QuoteResponse();
        qr.productQuotes = new List<ConsumerEligibleQuoteResponse.ProductQuotes>{pq};
        List<EligibleProductQuoteResult> results = EligibleProductQuoteResult.parse(qr, 'ADD');
        Assert.areEqual(1, results.size(), 'Should expect 1 ADD result');

        ipd.productCategory = 'Guaranteed UW WL';//Updating for life result
        ipd.aDnDInsuranceProductInfo = null;
        ipd.lifeInsuranceProductInfo = lipi;//Updating for life result
        qr.productQuotes = new List<ConsumerEligibleQuoteResponse.ProductQuotes>{pq};
        results = EligibleProductQuoteResult.parse(qr, 'Life');
        Assert.areEqual(1, results.size(), 'Should expect 1 life result');
    }

    @isTest
    private static void shouldParseResultTest() {
        ConsumerEligibleQuoteResponse.CoverageOptions co1 = new ConsumerEligibleQuoteResponse.CoverageOptions();
        co1.coverage = 3000;
        co1.frequency = 'Monthly';
        co1.premium = 3.00;

        List<ConsumerEligibleQuoteResponse.CoverageOptions> cos = new List<ConsumerEligibleQuoteResponse.CoverageOptions>{co1};

        ConsumerEligibleQuoteResponse.InsuranceProductDetails ipd = new ConsumerEligibleQuoteResponse.InsuranceProductDetails();
        ipd.insuranceProductDisplayName = 'Test Product';
        ipd.returnFlag = true;
        ipd.productCategory = 'ADD';

        ConsumerEligibleQuoteResponse.ProductQuotes pq = new ConsumerEligibleQuoteResponse.ProductQuotes();
        pq.productCode = 'Test';
        pq.insuranceProductDetails = ipd;
        pq.coverageOptions = cos;

        Boolean shouldParse = EligibleProductQuoteResult.shouldParseResult(pq, 'ADD');
        Assert.areEqual(true, shouldParse, 'Result should parse because product category is equal to product category from response');

        shouldParse = EligibleProductQuoteResult.shouldParseResult(pq, 'Guaranteed UW WL');
        Assert.areEqual(false, shouldParse, 'Result should not parse because product category is not equal to product category from response');
    }

    @isTest
    private static void parseResultInfoTest() {
        ConsumerEligibleQuoteResponse.InsuranceProductDetails ipd = new ConsumerEligibleQuoteResponse.InsuranceProductDetails();
        ipd.insuranceProductDisplayName = 'Test Product';

        ConsumerEligibleQuoteResponse.ProductQuotes pq = new ConsumerEligibleQuoteResponse.ProductQuotes();
        pq.productCode = 'Test';
        pq.insuranceProductDetails = ipd;

        EligibleProductQuoteResult result = EligibleProductQuoteResult.parseResultInfo(pq);
        Assert.areEqual('Test Product', result.productName, 'Product name is equal to product display name from response');
        Assert.areEqual('Test', result.productCode, 'Product code is equal to product code from response');
    }

    @isTest
    private static void parseCoverageOptionsTest() {
        ConsumerEligibleQuoteResponse.CoverageOptions co1 = new ConsumerEligibleQuoteResponse.CoverageOptions();
        co1.coverage = 3000;
        co1.frequency = 'Monthly';
        co1.premium = 3.00;

        List<ConsumerEligibleQuoteResponse.CoverageOptions> cos = new List<ConsumerEligibleQuoteResponse.CoverageOptions>{co1};
        List<EligibleProductQuoteResult.CoverageOption> cos2 =  EligibleProductQuoteResult.parseCoverageOptions(cos);
        Assert.areEqual('Monthly', cos2[0].frequency, 'Frequency is equal to frequency from response');
        Assert.areEqual(3000, cos2[0].coverage, 'Coverage is equal to coverage from response');
        Assert.areEqual(3.00, cos2[0].premium, 'Premium is equal to premium from response');
    }

    @isTest
    private static void parseBillingOptionsTest() {
        ConsumerEligibleQuoteResponse.EligibleBillingOptionsList ebol1 = new ConsumerEligibleQuoteResponse.EligibleBillingOptionsList();
        ebol1.billingMethodCode = 'ACH';
        ebol1.effectiveDate = '01/01/2024';

        List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList> ebol = new List<ConsumerEligibleQuoteResponse.EligibleBillingOptionsList>{ebol1};
        List<EligibleProductQuoteResult.BillingOption> bos = EligibleProductQuoteResult.parseBillingOptions(ebol);
        Assert.areEqual('ACH', bos[0].billingMethod, 'Billing method is equal to billing method from response');
        Assert.areEqual('01/01/2024', bos[0].effectiveDate, 'Effective date is equal to effective date from response');
    }

    @isTest
    private static void getProductCategoryTest() {
        String category = '';
        category = EligibleProductQuoteResult.getProductCategory('ADD');
        Assert.areEqual('ADD', category, 'Category is ADD');

        category = EligibleProductQuoteResult.getProductCategory('Conversion');
        Assert.areEqual('Conversion', category, 'Category is Conversion');

        category = EligibleProductQuoteResult.getProductCategory('Guaranteed UW WL');
        Assert.areEqual('Life', category, 'Category is Life');
    }
}