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

        /**
         * Teste la méthode getAccountsByIds de AccountController.
         * Vérifie qu'aucune exception n'est levée et que la méthode accepte une liste d'Id.
         */
        @isTest
        static void testGetAccountsByIds() {
            // Récupère un Id d'Account existant
            List<Account> accs = [SELECT Id FROM Account LIMIT 1];
            List<Id> ids = new List<Id>();
            if (!accs.isEmpty()) {
                ids.add(accs[0].Id);
            }
            Test.startTest();
            AccountController.getAccountsByIds(ids);
            Test.stopTest();
            // Pas d'assertion car la méthode ne retourne rien
        }
}