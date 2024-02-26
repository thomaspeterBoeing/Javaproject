/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHUtilities class
 */
@isTest
public with sharing class ILHUtilitiesTests {
    @isTest
    public static void getDIConsumerContainerTest() {
        List<DIConsumerContainer__mdt> containers = ILHUtilities.getDIConsumerContainer('ILHSalesSystemAdmin', 'ConsumerSearch');
        Assert.areEqual(1, containers.size(), 'Record found in container');
    }

    public static void getRateComparisonIntervalTest() {
        RateComparisonInterval__mdt rci = ILHUtilities.getRateComparisonInterval('ADD');
        Assert.areEqual('ADD', rci.MasterLabel, 'ADD record found');
    }
}