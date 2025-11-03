// Bad naming convention in method name to trigger PMD AnnotationsNamingConvention Medium rule.
// https://pmd.github.io/pmd/pmd_rules_apex_codestyle.html#annotationsnamingconventions
@isTest
private class AccountControllerTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(
            Name = 'Controller Test Account',
            Type = 'Customer',
            Phone = '555-123-4567'
        );
        insert testAccount;
    }
    // Bad naming convention in method name to trigger PMD AnnotationsNamingConvention Medium rule.
    // https://pmd.github.io/pmd/pmd_rules_apex_codestyle.html#annotationsnamingconventions
    @isTest
    static void testGetAllAccounts() {
        Test.startTest();
        List<Account> accounts = AccountController.getAllAccounts();
        Test.stopTest();
        
        // No error message to trigger PMD ApexAssertionsShouldIncludeMessage medium rule
        Assert.areEqual(1, accounts.size());
        Assert.areEqual('Controller Test Account', accounts[0].Name);
        
    }
}