/***
Copyright: TruStage
Purpose: Provides unit testing and code coverage for ILHMarketingHistoryFactory class.
1.0 - Adam Perschke-Ely - 11/2/2023  - Created for new D2C Salesfore instance.
***/
@isTest
public class ILHMarketingHistoryFactoryTests {
    @isTest
    private static void getInstancesTest() {
        List<IMarketingHistoryService> results = ILHMarketingHistoryFactory.getInstances();
        Assert.areEqual(1, results.size());
    }
}