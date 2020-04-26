/**
 * @Package: TestObjectDefaults_Test.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: See MIT License
 * @Uses: TestFactory.cls, TestObjectDefaults.cls
 *
 * -------------------------------------------------------------------
 * Description: Unit test to test the logic of the object defaults
 * We try to insert every object, so we can immediately detect if an object cannot inserted anymore.
 *
 * Created: 26/04/2020
 * Last Modified: 26/04/2020
 *
 * Changelog: 
 *
 */

@IsTest
private with sharing class TestObjectDefaults_Test {
    
    /**
     * @description of the test: create an account with the defaults
     *
     * Outcome: an account record, based on the defaults
     */
    @IsTest
    private static void testCreateAccount_Defaults() {
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(), true);
        Test.stopTest();
        
        System.assertEquals('TestAccount', a.Name);
    }
    
    /**
     * @description of the test: create an account with the specific defaults
     *
     * Outcome: an account record, based on the specific defaults
     */
    @IsTest
    private static void testCreateAccount_AccountSpecific() {
        Test.startTest();
        Account a = (Account) TestFactory.createSObject(new Account(), 'AccountSpecific', true);
        Test.stopTest();
        
        System.assertEquals('My Test Account', a.Name);
    }
    
    /**
     * @description of the test: create a user
     *
     * Outcome: a user created, following the defaults in the testObjectDefaults
     */
    @IsTest
    private static void testCreateUser_Defaults() {
        Test.startTest();
        User u = (User) TestFactory.createSObject(new User(), true);
        Test.stopTest();
        
        System.assertEquals('Testy', u.FirstName);
        System.assertEquals('the Tester', u.LastName);
        System.assertEquals('TestUser', u.Alias);
        System.assertEquals('testuser@tester.com', u.Email);
        System.assertEquals('UTF-8', u.EmailEncodingKey);
        System.assertEquals('en_US', u.LanguageLocaleKey);
        System.assertEquals('en_US', u.LocaleSidKey);
        System.assertEquals('Europe/Brussels', u.TimeZoneSidKey);
        System.assertEquals('testy.tester@unit-test.com', u.Username);
    }
    
    /**
     * @description of the test: create a contact
     *
     * Outcome: a contact created, following the defaults in the testObjectDefaults
     */
    @IsTest
    private static void testCreateContact_Defaults() {
        Test.startTest();
        Contact c = (Contact) TestFactory.createSObject(new Contact(), true);
        Test.stopTest();
        
        System.assertEquals('Testcontact', c.LastName);
    }
    
    /**
     * @description of the test: create a case
     *
     * Outcome: a case created, following the defaults in the testObjectDefaults
     */
    @IsTest
    private static void testCreateCase_Defaults() {
        Test.startTest();
        Case c = (Case) TestFactory.createSObject(new Case(), true);
        Test.stopTest();
        
        System.assertEquals('Test Case', c.Subject);
    }
    
    /**
     * @description of the test: create a Lead
     *
     * Outcome: a lead created, following the defaults in the testObjectDefaults
     */
    @IsTest
    private static void testCreateLead_Defaults() {
        Test.startTest();
        Lead l = (Lead) TestFactory.createSObject(new Lead(), true);
        Test.stopTest();
        
        System.assertEquals('Test Lead', l.LastName);
        System.assertEquals('Test Company', l.Company);
    }
    
    /**
     * @description of the test: create an opportunity
     *
     * Outcome: an opportunity created, following the defaults in the testObjectDefaults
     */
    @IsTest
    private static void testCreateOpportunity_Defaults() {
        Test.startTest();
        Opportunity o = (Opportunity) TestFactory.createSObject(new Opportunity(), true);
        Test.stopTest();
        
        System.assertEquals('Test Opportunity', o.Name);
    }
}