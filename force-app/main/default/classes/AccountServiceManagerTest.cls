@IsTest
private class AccountServiceManagerTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(
            Name = 'Service Test Account',
            Type = 'Prospect',
            Industry = 'Finance'
        );
        insert testAccount;
    }
    
    @IsTest
    static void testGetAllAccounts() {
        Test.startTest();
        List<Account> accounts = AccountServiceManager.getAllAccounts();
        Test.stopTest();
        
        Assert.areEqual(1, accounts.size(), 'Should return 1 account via service');
        Assert.areEqual('Service Test Account', accounts[0].Name, 'Account name should match');
    }
}