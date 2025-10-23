@isTest
private class ContactDataManagerTest {
    
    @isTest
    static void testGetAllContacts() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@test.com',
            Title = 'Manager',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Test.startTest();
        List<Contact> contacts = ContactDataManager.getAllContacts();
        Test.stopTest();
        
        Assert.areEqual(1, contacts.size(), 'Should return 1 contact');
        Assert.areEqual('Smith', contacts[0].LastName, 'Contact last name should match');
    }
}