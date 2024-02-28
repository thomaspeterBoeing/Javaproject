/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHUtilities class
 */
@isTest
public with sharing class ILHUtilitiesTests {
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
    private static void getDIConsumerContainerTest() {
        List<DIConsumerContainer__mdt> containers = ILHUtilities.getDIConsumerContainer('ILHSalesSystemAdmin', 'ConsumerSearch');
        Assert.isNotNull(containers, 'Container is not null');//TODO: Cannot check result while packaging, since the di container records are in a different package
    }

    @isTest
    private static void getRateComparisonIntervalTest() {
        RateComparisonInterval__mdt rci = ILHUtilities.getRateComparisonInterval('ADD');
        Assert.areEqual('ADD', rci.MasterLabel, 'ADD record found');
    }

    @isTest
    private static void getActiveProductsByProductCodeTest() {
        Map<String, String> productMap = ILHUtilities.getActiveProductsByProductCode();
        Assert.areEqual('Product1', productMap.get('Product 1'), 'Product found');
    }
}