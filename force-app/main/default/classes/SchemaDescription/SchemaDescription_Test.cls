/**
 * @Package: SchemaDescription_Test.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: See MIT License
 * @Uses: SchemaDescription.cls
 *
 * -------------------------------------------------------------------
 * Description: Unit tests to test the logic of the SchemaDescription class
 *
 * Created: 22/04/2020
 * Last Modified: 22/04/2020
 *
 * Changelog: 
 *
 */

@IsTest
private with sharing class SchemaDescription_Test {
    
    /**
     * @description of the test: test the constructor to define the object
     * Test the constructor with a valid object
     *
     * Outcome: the attribute 'objectType' of the SchemaDescription constructor may not be null and should be filled with the Account SObject description.
     */
    @IsTest
    private static void testConstructor() {
        Test.startTest();
        SchemaDescription sd = new SchemaDescription('Account');
        Test.stopTest();
        
        System.assertNotEquals(null, sd.objectType);
        System.assertEquals(Schema.SObjectType.Account.getName(), sd.objectType.getDescribe().name);
    }
    
    /**
     * @description of the test: test the constructor with a non existing object
     *
     * Outcome: you schould receive an exception.
     * the exception should contain the name of your object requested
     */
    @IsTest
    private static void testConstructorNonExisting() {
        String sNonExistingObject = 'testObject';
        try {
            Test.startTest();
            SchemaDescription sd = new SchemaDescription(sNonExistingObject);
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            System.assert(ex.getMessage().containsIgnoreCase(sNonExistingObject));
        }
    }
    
    /**
     * @description of the test: test the constructor without an object (the parameter is null)
     *
     * Outcome: you should receive an exception
     * the Exception should be the message in Label MESSAGE_MISSING_OBJECT
     */
    @IsTest
    private static void testConstructorWithoutObject() {
        try {
            Test.startTest();
            new SchemaDescription(null);
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            System.assertEquals(ex.getMessage(), Label.MESSAGE_MISSING_OBJECT);
        }
    }
    
    /**
     * @description of the test: test the functionality to get the map with recordtypes of an object
     *
     * Outcome: the map with the recordtypes from the object defined in the constructor
     * You have always a recordtype 'master' in the map with recordtypes
     */
    @IsTest
    private static void testGetMapRecordTypesByDeveloperName() {
        SchemaDescription sd = new SchemaDescription('Account');
        Test.startTest();
        Map<String, Schema.RecordTypeInfo> mapRecordTypes = sd.getMapRecordTypesByDeveloperName();
        Test.stopTest();
        
        System.assertNotEquals(null, mapRecordTypes);
        System.assertNotEquals(null, mapRecordTypes.get('Master'));
    }
}