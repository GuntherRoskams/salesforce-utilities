/**
 * @package RESTConnector_Test.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses TestFactory.cls
 * @author Gunther Roskams
 *
 * @description unit tests to test the basic logic of the REST Connector class
 *
 * @date 10-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
@IsTest
private class RESTConnector_Test {

    /**
     * @description of the test: test of the constructor
     * Outcome: a valid connector with basic functionality to connect to a REST Service
     */
    @IsTest
    private static void test_constructor() {
        Test.startTest();
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        RESTConnector oConnector = startConnector(null, mapHeaders);
        Test.stopTest();

        // verify the parameters in the connector class
        // the method is coming from the RESTAction object
        System.assertEquals('POST', oConnector.action.HTTPMethod);

        // the endpoint should come from the callout parameters
        System.assertEquals('http://localhost', oConnector.endpoint);

        // the map with headers
        System.assertEquals(mapHeaders, oConnector.action.mapHeaders);

        // the response object
        System.assertEquals('RESTConnector_Test.MockObject', oConnector.action.returnObject);
    }

    /**
     * @description of the test: test the constructor with a wrong http method
     * Outcome: an exception
     */
    @IsTest
    private static void test_constructor_WrongMethod() {
        // setup your data
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        TestCalloutParameters oParameters = new TestCalloutParameters(true);


        // perform the test
        Test.startTest();
        try {
            RESTAction oRestAction = new RESTAction('PULL', mapHeaders, null, '', 'type');
            new RESTConnector(oParameters, oRestAction);
            System.assert(false);
        } catch (GlobalException ex){
            System.assertEquals(GlobalUtils.repairPlaceHolders(Label.NOT_SUPPORTED_HTTP_METHOD, new Map<String, String>{'{0}' => 'PULL'}), ex.getMessage());
        }
        Test.stopTest();
    }

    /**
     * @description of the test: test of the base connector without a method
     * Outcome: A connector with the GET method, this is the default
     */
    @IsTest
    private static void test_constructor_EmptyMethod() {
        // setup your data
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        TestCalloutParameters oParameters = new TestCalloutParameters(true);
        RESTAction oRestAction = new RESTAction(null, mapHeaders, null, 'RESTConnector_Test.MockObject', 'type');

        // perform the test
        Test.startTest();
        RESTConnector oConnector = new RESTConnector(oParameters, oRestAction);
        Test.stopTest();

        // verify the result
        System.assertEquals(oRestAction.DEFAULT_HTTP_METHOD, oConnector.action.HTTPMethod);
    }

    /**
     * @description of the test: test the construction of the headers
     * Outcome: a map with headers
     */
    @IsTest
    private static void test_constructHeaders() {
        // setup your data
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'application/json',
                'Authorization' => 'token'
        };

        // perform the test
        Test.startTest();
        RESTConnector oConnector = startConnector(null, mapHeaders);
        Map<String, String> oMapHeaders = oConnector.constructHeaders();
        Test.stopTest();

        // verify the result
        System.assertEquals(2, oMapHeaders.size());
        System.assertEquals(mapHeaders, oMapHeaders);
    }

    /**
     * @description of the test: test the construction of the headers without a map
     * Outcome: an empty map for the headers
     */
    @IsTest
    private static void test_constructHeadersWithoutMap() {
        // setup your data
        RESTConnector oConnector = startConnector(null, null);

        // perform the test
        Test.startTest();
        Map<String, String> oMapHeaders = oConnector.constructHeaders();
        Test.stopTest();

        // verify the result
        System.assertEquals(0, oMapHeaders.size());
    }

    /**
     * @description of the test: test the construction of the body (String)
     * Outcome: the string of the action in the body of the connector
     */
    @IsTest
    private static void test_constructBody() {
        // setup your data
        String sBody = '{"message" : "This is a test body"}';
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'Application/json'
        };

        // perform the test
        Test.startTest();
        RESTConnector oConnector = startConnector(sBody, mapHeaders);
        Object oBody = oConnector.constructBody();
        Test.stopTest();

        // verify the result
        System.assertEquals(sBody, (String) oBody);
    }

    /**
     * @description of the test: test the construction of the body (Blob)
     * Outcome: the Blob of the action in the body of the connector
     */
    @IsTest
    private static void test_constructBody_Blob() {
        // setup your data
        Blob blBody = Blob.valueOf('{"message" : "This is a test body"}');
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'Application/json'
        };

        // perform the test
        Test.startTest();
        RESTConnector oConnector = startConnector(blBody, mapHeaders);
        Object oBody = oConnector.constructBody();
        Test.stopTest();

        // verify the result
        System.assertEquals(blBody, (Blob) oBody);
    }

    /**
     * @description of the test: construct the body of your request without a body
     * Outcome: the body constructed for the connector
     */
    @IsTest
    private static void test_constructBody_withoutBody() {
        // setup your data
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'Application/json'
        };

        // perform the test
        Test.startTest();
        RESTConnector oConnector = startConnector(null, mapHeaders);
        String sBody = (String) oConnector.constructBody();
        Test.stopTest();

        // verify the result
        System.assertEquals('',sBody);
    }

    /**
     * @description of the test: test of the callout functionality
     * Outcome: a valid callout process with a valid response
     */
    @IsTest
    private static void test_callout_string() {
        // setup your data
        createMockResponse(200, 'OK');
        String sBody = '{"message" : "this is a test"}';
        // perform the test
        Test.startTest();
        RESTConnector oConnector = startConnector(sBody, null);
        oConnector.constructHeaders();
        oConnector.constructBody();
        ResponseObject oResponse = oConnector.callout();
        Test.stopTest();

        // verify the result
        // the is 1 result in the list items. The JSON is converted to a MockObject record
        System.assertEquals(1, oResponse.listItems.size());

        // verify the object created
        MockObject oMockObject = (MockObject) oResponse.listItems[0];
        System.assertEquals('this is a test message in JSON',oMockObject.message);
        System.assert(oResponse.stringCompleteResponse.containsIgnoreCase('this is a test message in JSON'));

        // verify the headers
        System.assertEquals(1, oResponse.mapResponseHeaders.size());
        System.assertEquals('application/json',oResponse.mapResponseHeaders.get('Content-Type'));
    }

    /**
     * @description of the test: test of the callout functionality
     * Outcome: a valid callout process with a valid response
     */
    @IsTest
    private static void test_callout_blob() {
        // setup your data
        createMockResponse(200, 'OK');
        Blob blBody = Blob.valueOf('{"message" : "this is a test"}');
        // perform the test
        Test.startTest();
        RESTConnector oConnector = startConnector(blBody, null);
        oConnector.constructHeaders();
        oConnector.constructBody();
        ResponseObject oResponse = oConnector.callout();
        Test.stopTest();

        // verify the result
        // the is 1 result in the list items. The JSON is converted to a MockObject record
        System.assertEquals(1, oResponse.listItems.size());

        // verify the object created
        MockObject oMockObject = (MockObject) oResponse.listItems[0];
        System.assertEquals('this is a test message in JSON',oMockObject.message);
        System.assert(oResponse.stringCompleteResponse.containsIgnoreCase('this is a test message in JSON'));

        // verify the headers
        System.assertEquals(1, oResponse.mapResponseHeaders.size());
        System.assertEquals('application/json',oResponse.mapResponseHeaders.get('Content-Type'));
    }

    /**
     * @description of the test: test the callout with an incorrect object
     * Outcome: an exception
     */
    @IsTest
    private static void test_CalloutWithWrongObject() {
        // setup your data
        createMockResponse(200, 'OK');
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'application/json'
        };
        TestCalloutParameters oParameters = new TestCalloutParameters(true);
        // set an action with an objec that not exists
        RESTAction oRestAction = new RESTAction('POST', mapHeaders, null, 'a_WrongObject','type');

        RESTConnector oConnector = new RESTConnector(oParameters, oRestAction);
        oConnector.setPossibleActionNames = new Set<String>{'type'};

        // perform the test
        try {
            Test.startTest();
            oConnector.constructHeaders();
            oConnector.constructBody();
            oConnector.callout();
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            System.assert(ex.getMessage().containsIgnoreCase('APEXOBJECT_DOES_NOT_EXIST'));
            System.assert(ex.getMessage().containsIgnoreCase('a_WrongObject'));
        }
    }

    /**
     * @description of the test: test of the callout with a wrong action name
     * Outcome: an exception
     */
    @IsTest
    private static void test_calloutWithWrongActiontype() {
        // setup your data
        createMockResponse(200, 'OK');
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'application/json'
        };
        TestCalloutParameters oParameters = new TestCalloutParameters(true);
        // set an action with an objec that not exists
        RESTAction oRestAction = new RESTAction('POST', mapHeaders, null, 'RESTConnector_Test.MockObject','testType');

        RESTConnector oConnector = new RESTConnector(oParameters, oRestAction);
        oConnector.setPossibleActionNames = new Set<String>{'type'};

        // perform the test
        try {
            Test.startTest();
            oConnector.constructHeaders();
            oConnector.constructBody();
            oConnector.callout();
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            // verify the result
            System.assert(ex.getMessage().containsIgnoreCase('ACTION_NOT_SUPPORTED'));
            System.assert(ex.getMessage().containsIgnoreCase('testType'));
        }
    }

    /**
     * @description of the test: test the callout, but we receive an exception
     * We perform a DML before the callout. This is not allowed by Salesforce and generates an exception
     * Outcome: an exception
     */
    @IsTest
    private static void test_CalloutException() {
        // setup your data
        createMockResponse(200, 'OK');

        // perform the test
        try {
            Test.startTest();
            TestFactory.createSObject(new Account(), true);
            RESTConnector oConnector = startConnector(null, null);
            oConnector.constructHeaders();
            oConnector.constructBody();
            oConnector.callout();
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            // verify the result
            System.assert(ex.getMessage().containsIgnoreCase('REST_CALLOUT_ERROR'));
        }
    }

    /**
     * @description of the test: test the callout with another response code (error 500)
     * Outcome: an exception, because I put the error handling to true
     */
    @IsTest
    private static void test_CalloutHTTPError() {
        // setup your data
        createMockResponse(500, 'Internal Server Error');
        // perform the test
        try {
            Test.startTest();
            RESTConnector oConnector = startConnector(null, null);
            oConnector.constructHeaders();
            oConnector.constructBody();
            oConnector.callout();
            System.assert(false);
            Test.stopTest();
        } catch (GlobalException ex){
            // verify the result
            System.assert(ex.getMessage().containsIgnoreCase('ERR_CALLOUT'));
            System.assert(ex.getMessage().containsIgnoreCase('500'));
            System.assert(ex.getMessage().containsIgnoreCase('Internal Server Error'));
        }
    }

    /**
     * @description of the test: we perform a call with a no 200 response, but we don't get an exception, due to the error handling is false in the callout parameters
     * Outcome: a response object with the correct response code and message, but no exception
     */
    @IsTest
    private static void test_CalloutWithoutErrorHandling() {
        // setup your data
        createMockResponse(404, 'Not Found');
        TestCalloutParameters oCalloutParameters = new TestCalloutParameters(false);
        RESTAction oRestAction = new RESTAction('POST', null, null, 'RESTConnector_Test.MockObject','type');
        RESTConnector oConnector = new RESTConnector(oCalloutParameters, oRestAction);
        oConnector.setPossibleActionNames = new Set<String>{'type'};
        // perform the test
        Test.startTest();
        oConnector.constructHeaders();
        oConnector.constructBody();
        ResponseObject oResponseObject = oConnector.callout();
        Test.stopTest();

        // verify the result
        System.assertEquals(404, oResponseObject.responseStatusCode);
        System.assertEquals('Not Found', oResponseObject.responseStatusMessage);
    }

    /**
     * @description of the test: test the logic of the patch mathod
     * Outcome: the url is extended with the extension _HttpMethod=PATCH
     */
    @IsTest
    private static void test_patchMethod() {
        // setup your data
        createMockResponse(200, 'OK');
        TestCalloutParameters oCalloutParameters = new TestCalloutParameters(false);
        RESTAction oRestAction = new RESTAction('PATCH', null, null, 'RESTConnector_Test.MockObject','type');
        RESTConnector oConnector = new RESTConnector(oCalloutParameters, oRestAction);
        oConnector.setPossibleActionNames = new Set<String>{'type'};
        // perform the test
        Test.startTest();
        oConnector.constructHeaders();
        oConnector.constructBody();
        oConnector.callout();
        Test.stopTest();

        // verify the result
        System.assert(oConnector.endpoint.containsIgnoreCase('_HttpMethod=PATCH'));
    }


    /**
     * Supporting method to help execute the tests above
     *
     *
     * @description Helper method to create a basic connector
     *
     * @param oBody an object (String or Blob) with a body
     * @param mapHeaders a map with request headers
     *
     * @return a connector instance
     */
    private static RESTConnector startConnector(Object oBody, Map<String, String> mapHeaders){
        TestCalloutParameters oParameters = new TestCalloutParameters(true);
        RESTAction oRestAction = new RESTAction('POST', mapHeaders, oBody, 'RESTConnector_Test.MockObject', 'type');
        RESTConnector oConnector = new RESTConnector(oParameters, oRestAction);
        oConnector.setPossibleActionNames = new Set<String>{'type'};

        return oConnector;
    }

    /**
     * @description create a mock response to perform a callout during the tests above
     *
     * @param iStatusCode the HTTP status response code
     * @param sStatus the HTTP status message
     */
    private static void createMockResponse(Integer iStatusCode, String sStatus){
        Map<String, String> mapHeaders = new Map<String, String>{
                'Content-Type' => 'application/json'
        };
        String sBody = '{"message" : "this is a test message in JSON"}';

        MockService.CalloutMockService oMockService = new MockService.CalloutMockService(iStatusCode, sStatus, sBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, oMockService);
    }

    /**
     * @description a definition of Test callout parameters to use to test the REST Connector
     */
    public class TestCalloutParameters implements RESTConnector.CalloutParameters {
        private Boolean errorHandling = false;

        public TestCalloutParameters(Boolean bErrorHandling){
            this.errorHandling = bErrorHandling;
        }

        public String getEndpoint(){
            return 'http://localhost';
        }

        public Integer getTimeout(){
            return 20000;
        }

        public Boolean getErrorHandling(){
            return this.errorHandling;
        }
    }

    /**
     * @description a test object to test the REST Connector
     */
    public class MockObject extends ResponseObject.ResponseItem {
        public String message {get; set;}
    }
}