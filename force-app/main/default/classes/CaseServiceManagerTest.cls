@isTest
private class CaseServiceManagerTest {
    
    @isTest
    static void testGetAllCases() {
        Account testAccount = new Account(Name = 'Service Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Service',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Case testCase = new Case(
            Subject = 'Service Test Case',
            Status = 'Working',
            Priority = 'High',
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert testCase;
        
        Test.startTest();
        List<Case> cases = CaseServiceManager.getAllCases();
        Test.stopTest();
        
        Assert.areEqual(1, cases.size(), 'Should return 1 case via service');
        Assert.areEqual('Service Test Case', cases[0].Subject, 'Case subject should match');
    }
}