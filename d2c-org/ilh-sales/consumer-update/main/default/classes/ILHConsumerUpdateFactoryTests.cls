/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHConsumerUpdateFactory class
 */
@isTest
public class ILHConsumerUpdateFactoryTests {
    @isTest
    public static void getInstancesTest() {
        Assert.isTrue(ILHConsumerUpdateFactory.getInstances().size() > 0);
    }
}