@IsTest
private class AccountDataManagerTest {
    
    @IsTest
    static void testGetAllAccounts() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer',
            Industry = 'Technology'
        );
        insert testAccount;
        
        Test.startTest();
        List<Account> accounts = AccountDataManager.getAllAccounts();
        Test.stopTest();
        Assert.areEqual(1, accounts.size(), 'Should return 1 account');
        Assert.areEqual('Test Account', accounts[0].Name, 'Account name should match');
    }
}