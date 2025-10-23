@isTest
private class CaseControllerTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Controller Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Controller',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Case testCase = new Case(
            Subject = 'Controller Test Case',
            Status = 'New',
            Priority = 'Medium',
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert testCase;
    }
    
    @isTest
    static void testGetAllCases() {
        Test.startTest();
        List<Case> cases = CaseController.getAllCases();
        Test.stopTest();
        
        Assert.areEqual(1, cases.size(), 'Should return 1 case via controller');
        Assert.areEqual('Controller Test Case', cases[0].Subject, 'Case subject should match');
    }
}