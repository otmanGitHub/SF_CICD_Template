@isTest
private class CaseDataManagerTest {
    
    @isTest
    static void testGetAllCases() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Priority = 'Medium',
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert testCase;
        
        Test.startTest();
        List<Case> cases = CaseDataManager.getAllCases();
        Test.stopTest();
        
        Assert.areEqual(1, cases.size(), 'Should return 1 case');
        Assert.areEqual('Test Case', cases[0].Subject, 'Case subject should match');
    }
}