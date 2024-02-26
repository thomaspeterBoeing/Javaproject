/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHUtilities class
 */
@isTest
public with sharing class ILHUtilitiesTests {
    @isTest
    public static void getDIConsumerContainerTest() {
        List<DIConsumerContainer__mdt> containers = ILHUtilities.getDIConsumerContainer('ILHSalesSystemAdmin', 'ConsumerSearch');
        Assert.isNotNull(containers, 'Container is not null');//TODO: Cannot check result while packaging, since the di container records are in a different package
    }

    public static void getRateComparisonIntervalTest() {
        RateComparisonInterval__mdt rci = ILHUtilities.getRateComparisonInterval('ADD');
        Assert.areEqual('ADD', rci.MasterLabel, 'ADD record found');
    }
}