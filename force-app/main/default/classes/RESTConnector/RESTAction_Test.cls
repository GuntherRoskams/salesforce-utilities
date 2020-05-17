/**
 * @package RestAction_Test.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses 
 * @author Gunther Roskams
 *
 * @description unit tests to test the logic to create a REST Action
 *
 * @date 05-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
@IsTest
private class RESTAction_Test {

    /**
     * @description of the test: test the constructor of the action
     * Outcome: a valid constructor
     */
    @IsTest
    private static void test_constructor() {
        // setup your data
        String sMethod = 'GET';
        Map<String, String> mapHeaders = new Map<String, String>{'Accept' => 'application/json'};
        String sBody = '{"name" : "this is a test"}';
        String sReturnObject = 'Account';
        String sActionName = 'getFields';

        // perform the test
        Test.startTest();
        RESTAction oAction = new RESTAction(sMethod, mapHeaders, sBody, sReturnObject, sActionName);
        Test.stopTest();

        // Verify the result
        System.assertEquals('GET', oAction.HTTPMethod);
        System.assertEquals('application/json', oAction.mapHeaders.get('Accept'));
        System.assertEquals(sActionName, oAction.name);
        System.assertEquals(sBody, oAction.body);
        System.assertEquals(sReturnObject, oAction.returnObject);
    }

    /**
     * @description of the test: test the constructor of a REST Action, with incorrect parameters
     * Outcome: an Exception
     */
    @IsTest
    private static void test_ConstructorWithWrongMethod() {
        // setup your data
        String sMethod = 'TEST';
        Map<String, String> mapHeaders = new Map<String, String>{'Accept' => 'application/json'};
        String sBody = '{"name" : "this is a test"}';
        String sReturnObject = 'Account';
        String sActionName = 'getFields';

        // perform the test
        try {
            Test.startTest();
            new RESTAction(sMethod, mapHeaders, sBody, sReturnObject, sActionName);
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            // verify the result
            System.assert(ex.getMessage().containsIgnoreCase(sMethod));
        }
    }
}