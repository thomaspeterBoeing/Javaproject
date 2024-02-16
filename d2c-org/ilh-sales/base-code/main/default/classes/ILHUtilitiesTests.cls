/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHUtilities class
 */
@isTest
public class ILHUtilitiesTests {
    @isTest
    public static void getDIConsumerContainerTest() {
        List<DIConsumerContainer__mdt> containers = ILHUtilities.getDIConsumerContainer('ILHSalesSystemAdmin', 'ILHSearchFactory');
        Assert.areEqual(1, containers.size());
    }
}