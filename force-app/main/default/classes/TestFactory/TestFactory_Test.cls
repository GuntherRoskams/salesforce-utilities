/**
 * @Package: TestFactory_Test.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: See MIT License
 * @Uses: TestFactory.cls, TestObjectDefaults.cls
 *
 * -------------------------------------------------------------------
 * @description: Unit tests to test the functionality of the testing framework
 * We will create Account records to test all the logic
 *
 * Created: 25/04/2020
 * Last Modified: 25/04/2020
 *
 * Changelog: 
 *
 */
@IsTest
private with sharing class TestFactory_Test {
    
    /**
     * @description of the test: create a test account with only the SObject
     *
     * Outcome: an Account created with the fields provided
     */
    @IsTest
    private static void testCreateSObject_scenario1() {
        String sAccountNumber = 'G-1234';
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(AccountNumber = sAccountNumber));
        Test.stopTest();
        
        // get the name of the account, this should be the name of the default values (configured in the TestObjectDefaults.cls)
        System.assertEquals('TestAccount', a.Name);
        
        // check the accountnumber
        System.assertEquals(sAccountNumber, a.AccountNumber);
        
        // the Account should not inserted into the database
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE AccountNumber = :sAccountNumber]);
    }
    
    /**
     * @description of the test: create a test account with the object and the possibility to add the Account into the database
     * We insert the account into the database
     *
     * Outcome: an account, inserted into the database
     */
    @IsTest
    private static void testCreateSObject_scenario2() {
        String sAccountNumber = 'G-1234';
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(AccountNumber = sAccountNumber), true);
        Test.stopTest();
        
        // select the account
        Account aSelected = [SELECT Id, AccountNumber, Name FROM Account WHERE Id = :a.Id];
        
        // verify the different fields
        System.assertEquals('TestAccount', aSelected.Name);
        System.assertEquals(sAccountNumber, aSelected.AccountNumber);
        System.assertNotEquals(null, aSelected.Id);
        System.assertEquals(a.Id, aSelected.Id);
    }
    
    /**
     * @description of the test: create a test account with the object and a specific class name.
     *
     * Outcome: an object created with the name of the specific class
     */
    @IsTest
    private static void testCreateSObject_scenario3() {
        String sAccountNumber = 'G-1234';
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(AccountNumber = sAccountNumber), 'AccountSpecific');
        Test.stopTest();
        
        // check if the account has the name of the class 'AccountSpecific'
        System.assertEquals('My Test Account', a.Name);
        System.assertEquals(sAccountNumber, a.AccountNumber);
    }
    
    /**
     * @description of the test: create a test account with a wrong specific class (not written in the TestObjectefaults class)
     *
     * Outcome: an exception with the message 'DEFAULTS_CLASS_DOES_NOT_EXIST' in the code
     */
    @IsTest
    private static void testCreateSObject_scenario4() {
        String sDefaultsClass = 'ClassThatNotExists';
        try {
            Test.startTest();
            TestFactory.createSObject(new Account(), sDefaultsClass);
            Test.stopTest();
            System.assert(false);
        } catch (GlobalException ex){
            System.assert(ex.getMessage().containsIgnoreCase('DEFAULTS_CLASS_DOES_NOT_EXIST'));
            
            // the name of the class should be in the error message
            System.assert(ex.getMessage().containsIgnoreCase(sDefaultsClass));
        }
    }
    
    /**
     * @description of the test: create a test account with the complete function (a custom defaults class and the insert into the database)
     *
     * Outcome:a test account created into the database, with the defintions of the custom defaults class
     */
    @IsTest
    private static void testCreateSObject_scenario5() {
        String sAccountNumber = 'G-1234';
        
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(AccountNumber = sAccountNumber), 'AccountSpecific', true);
        Test.stopTest();
        
        // Select the created Account
        Account aSelected = [SELECT Id, AccountNumber, Name FROM Account WHERE AccountNumber = :sAccountNumber];
        
        // verify the fields
        System.assertEquals('My Test Account', aSelected.Name);
        System.assertEquals(sAccountNumber, aSelected.AccountNumber);
        System.assertEquals(a.Id, aSelected.Id);
    }
    
    /**
     * @description of the test: create a test object where the defaults does not exist. We create a test profile (you don't need to create that, you can select that via SOQL)
     *
     * Outcome:an exception
     */
    @IsTest
    private static void testCreateSObject_scenario6() {
        try {
            Test.startTest();
            TestFactory.createSObject(new Profile());
            Test.stopTest();
            System.assert(false);
        } catch (GlobalException ex){
            System.assert(ex.getMessage().containsIgnoreCase('DEFAULTS_CLASS_DOES_NOT_EXIST'));
            // verify if the defaults class is present in the message (the object API name + 'Defaults')
            System.assert(ex.getMessage().containsIgnoreCase('ProfileDefaults'));
        }
    }
    
    /**
     * @description of the test: create a list of test accounts, with just the object and the number of accounts that need to be created
     *
     * Outcome: a list of 5 accounts, all with a different name
     */
    @IsTest
    private static void testCreateSObjectList_scenario1() {
        Integer iNumberOfAccounts = 5;
        Test.startTest();
        List<Account> lstAccounts = (List<Account>) TestFactory.createSObjectList(new Account(Name = 'Test Create Account List'), iNumberOfAccounts);
        Test.stopTest();
        
        System.assertEquals(iNumberOfAccounts, lstAccounts.size());
        Integer iNumberIntheList = 1;
        for (Account a : lstAccounts){
            System.assertEquals('Test Create Account List ' + String.valueOf(iNumberIntheList), a.Name);
            iNumberIntheList++;
        }
    }
    
    /**
     * @description of the test: create a list of test accounts, with the object, the number of accounts that need to be created and the possibility to insert the list into the database
     *
     * Outcome: a list with accounts, inserted into the database
     */
    @IsTest
    private static void testCreateSObjectList_scenario2() {
        Integer iNumberOfAccounts = 5;
        String sAccountName = 'Test Create Account List';
        Test.startTest();
        
        TestFactory.createSObjectList(new Account(Name = sAccountName), iNumberOfAccounts, true);
        Test.stopTest();
        
        // select the accounts from the database
        List<Account> lstAccountsSelected = [SELECT Id, Name FROM Account WHERE Name LIKE :sAccountName + '%'];
        
        // check the number of the records in the list. This should be the same as we want to create
        System.assertEquals(iNumberOfAccounts, lstAccountsSelected.size());
        
        // loop through the records and verify the name of each record
        Integer iNumberInTheList = 1;
        for (Account a : lstAccountsSelected){
            System.assertEquals(sAccountName + ' ' + String.valueOf(iNumberInTheList), a.Name);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: create a list of test accounts, with the object, the number of accounts that need to be created and define the defaults from a specific class
     *
     * Outcome: a list with accounts with the parameters, coming from a specific defaults class
     */
    @IsTest
    private static void testCreateSObjectList_scenario3() {
        Integer iNumberOfAccounts = 5;
        Test.startTest();
        List<Account> lstAccounts = (List<Account>) TestFactory.createSObjectList(new Account(), iNumberOfAccounts, 'AccountSpecific');
        Test.stopTest();
        
        System.assertEquals(iNumberOfAccounts, lstAccounts.size());
        
        // verify the name of the accounts. This should be the field value of the the name in the defaults class 'AccountSpecific'
        Integer iNumberInTheList = 1;
        for (Account a : lstAccounts){
            System.assertEquals('My Test Account ' + String.valueOf(iNumberInTheList), a.Name);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: create list of test accounts, with the object, the number of the accounts that need to be created, the field definition of a specific defaults class and inserted into the database
     *
     * Outcome: a list with accounts, created into the database with the parameters from a specific defaults class
     */
    @IsTest
    private static void testCreateSObjectList_scenario4() {
        Integer iNumberOfAccounts = 5;
        Test.startTest();
        TestFactory.createSObjectList(new Account(), iNumberOfAccounts, 'AccountSpecific', true);
        Test.stopTest();
        
        // select the accounts from the database. The parameter in the WHERE clause is the name in the defaults class 'AccountSpecific
        List<Account> lstAccountsSelected = [SELECT Id, Name FROM Account WHERE Name LIKE 'My Test Account %'];
        
        // Verify the number of accounts, this should be the same number as we want to create
        System.assertEquals(iNumberOfAccounts, lstAccountsSelected.size());
        
        // verify the name of each account
        Integer iNumberInTheList = 1;
        for (Account a : lstAccountsSelected){
            System.assertEquals('My Test Account ' + String.valueOf(iNumberInTheList), a.Name);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: Create a list of users, to cover the specific requirements for the user object
     *
     * Outcome: a list of users
     */
    @IsTest
    private static void testCreateSObjectList_scenario5() {
        Integer iNumberOfUsers = 5;
        Test.startTest();
        List<User> lstUsers = (List<User>) TestFactory.createSObjectList(new User(), iNumberOfUsers);
        Test.stopTest();
        
        System.assertEquals(iNumberOfUsers, lstUsers.size());
        
        Integer iNumberInTheList = 1;
        for (User u : lstUsers){
            System.assertEquals('testy.tester@unit-test.com_' + iNumberInTheList, u.Username);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: create a list of contacts, to cover the specific requirements for the contact object
     *
     * Outcome: a list of contacts
     */
    @IsTest
    private static void testCreateSObjectList_scenario6() {
        Integer iNumberOfcontacts = 5;
        Test.startTest();
        List<Contact> lstContacts = (List<Contact>) TestFactory.createSObjectList(new Contact(), iNumberOfcontacts);
        Test.stopTest();
    
        System.assertEquals(iNumberOfcontacts, lstContacts.size());
    
        Integer iNumberInTheList = 1;
        for (Contact c : lstContacts){
            System.assertEquals('Testcontact ' + iNumberInTheList, c.LastName);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: create a list of cases, to cover the specific requirements for the case object
     *
     * Outcome: a list of case
     */
    @IsTest
    private static void testCreateSObjectList_scenario7() {
        Integer iNumberOfCases = 5;
        Test.startTest();
        List<Case> lstCases = (List<Case>) TestFactory.createSObjectList(new Case(), iNumberOfCases);
        Test.stopTest();
        
        System.assertEquals(iNumberOfCases, lstCases.size());
        
        Integer iNumberInTheList = 1;
        for (Case c : lstCases){
            System.assertEquals('Test Case ' + iNumberInTheList, c.Subject);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: create a list of leads, to cover the specific requirements for the lead object
     *
     * Outcome: a list of leads
     */
    @IsTest
    private static void testCreateSObjectList_scenario8() {
        Integer iNumberOfLeads = 5;
        Test.startTest();
        List<Lead> lstLeads = (List<Lead>) TestFactory.createSObjectList(new Lead(), iNumberOfLeads);
        Test.stopTest();
        
        System.assertEquals(iNumberOfLeads, lstLeads.size());
        
        Integer iNumberInTheList = 1;
        for (Lead l : lstLeads){
            System.assertEquals('Test Lead ' + iNumberInTheList, l.Company);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: create a list of opportunity, to cover the other objects
     *
     * Outcome: a list of opportunities
     */
    @IsTest
    private static void testCreateSObjectList_scenario9() {
        Integer iNumberOfOpportunities = 5;
        Test.startTest();
        List<Opportunity> lstOpportunities = (List<Opportunity>) TestFactory.createSObjectList(new Opportunity(), iNumberOfOpportunities);
        Test.stopTest();
        
        System.assertEquals(iNumberOfOpportunities, lstOpportunities.size());
        
        Integer iNumberInTheList = 1;
        for (Opportunity o : lstOpportunities){
            System.assertEquals('Test Opportunity ' + iNumberInTheList, o.Name);
            iNumberInTheList++;
        }
    }
    
    /**
     * @description of the test: test the logic to assign specific defaults to a record
     *
     * Outcome: a recrod created with a specific class
     */
    @IsTest
    private static void testSetObjectSpecifics() {
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(), 'AccountSpecific');
        Test.stopTest();
        
        System.assertEquals('My Test Account', a.Name);
    }
}