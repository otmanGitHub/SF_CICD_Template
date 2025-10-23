@isTest
private class ContactServiceManagerTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Service Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Service',
            LastName = 'Manager',
            Email = 'service.manager@test.com',
            AccountId = testAccount.Id
        );
        insert testContact;
    }
    
    @isTest
    static void testGetAllContacts() {
        Test.startTest();
        List<Contact> contacts = ContactServiceManager.getAllContacts();
        Test.stopTest();
        
        Assert.areEqual(1, contacts.size(), 'Should return 1 contact via service');
        Assert.areEqual('Manager', contacts[0].LastName, 'Contact last name should match');
    }
}