@isTest
private class ContactControllerTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Controller Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Controller',
            LastName = 'TestContact',
            Email = 'controller.test@test.com',
            AccountId = testAccount.Id
        );
        insert testContact;
    }
    
    @isTest
    static void testGetAllContacts() {
        Test.startTest();
        List<Contact> contacts = ContactController.getAllContacts();
        Test.stopTest();
        
        Assert.areEqual(1, contacts.size(), 'Should return 1 contact via controller');
        Assert.areEqual('TestContact', contacts[0].LastName, 'Contact last name should match');
    }
}