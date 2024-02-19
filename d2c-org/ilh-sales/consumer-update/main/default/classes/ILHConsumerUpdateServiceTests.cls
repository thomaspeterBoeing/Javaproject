/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHConsumerUpdateService class
 */
@isTest
public class ILHConsumerUpdateServiceTests {
    @isTest
    public static void sendUpdateTest() {
        Map<String, Object> kvp = new Map<String, Object>();
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'Test'
        );
        kvp.put('account', acc);
        kvp.put('commituser', UserInfo.getUserId());
        new ILHConsumerUpdateService().sendUpdate(kvp);
    }
}