/**
 * @package MockService_Test.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses 
 * @author Gunther Roskams
 *
 * @description 
 *
 * @date 07-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
@IsTest
private class MockService_Test {

    /**
     * @description of the test: test of the costructor logic
     * Outcome: a valid constructor with an empty map for the mock services
     */
    @IsTest
    private static void test_constructor() {
        Test.startTest();
        MockService oMockService = new MockService();
        Test.stopTest();

        System.assertEquals(0, oMockService.mapMockServices.size());
    }

    /**
     * @description of the test: test of the constructor with a map
     * Outcome: the mockservice record with 2 services
     */
    @IsTest
    private static void test_constructorWithMap(){
        // setup your data
        Integer iStatusCode = 200;
        String sStatusMessage = 'OK';
        String sBody = '{"test" : "message"}';
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};

        // perform the test
        Test.startTest();
        MockService.CalloutMockService oCalloutService = new MockService.CalloutMockService(iStatusCode, sStatusMessage, sBody, mapHeaders);
        MockService oMockService = new MockService(new Map<String, MockService.CalloutMockService>{
                '.+endpoint.+' => oCalloutService,
                '.+endpoint2.+' => oCalloutService
        });
        Test.stopTest();

        // verify the result
        System.assertEquals(2, oMockService.mapMockServices.size());
        System.assertEquals(oCalloutService, oMockService.mapMockServices.get('.+endpoint2.+'));
        System.assertEquals(oCalloutService, oMockService.mapMockServices.get('.+endpoint.+'));
    }

    /**
     * @description of the test: test of the registering of a mock service
     * Outcome: an object with a map with the registered mockservice
     */
    @IsTest
    private static void test_RegisterMockService() {
        // setup your data
        Integer iStatusCode = 200;
        String sStatusMessage = 'OK';
        String sBody = '{"test" : "message"}';
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};

        MockService.CalloutMockService oCalloutService = new MockService.CalloutMockService(iStatusCode, sStatusMessage, sBody, mapHeaders);

        // perform the test
        Test.startTest();
        MockService oMockService = new MockService();
        oMockService.registerCalloutMockService('.+endpoint.+', oCalloutService);
        Test.stopTest();

        // verify the result
        System.assertEquals(1, oMockService.mapMockServices.size());
        System.assertEquals(oCalloutService, oMockService.mapMockServices.get('.+endpoint.+'));
    }

    /**
     * @description of the test: test the respond method of the mock service, with a single request, with a string as body
     * A request is sent to the service and generates the response
     * Outcome: a generated response from the request
     */
    @IsTest
    private static void test_ResponseWithString_SingleRequest() {
        // setup your data
        Integer iStatusCode = 200;
        String sStatusMessage = 'OK';
        String sBody = '{"test" : "message"}';
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};

        HttpRequest oHttpRequest = new HttpRequest();
        oHttpRequest.setEndpoint('/endpoint/theUrl');

        // perform the test
        Test.startTest();
        MockService oMockService = new MockService(new Map<String, MockService.CalloutMockService>{
                '.+endpoint.+' => new MockService.CalloutMockService(iStatusCode, sStatusMessage, sBody, mapHeaders)
        });
        HttpResponse oHttpResponse = oMockService.respond(oHttpRequest);
        Test.stopTest();

        // verify the result
        System.assertEquals(sBody, oHttpResponse.getBody());
        System.assertEquals(iStatusCode, oHttpResponse.getStatusCode());
        System.assertEquals(sStatusMessage, oHttpResponse.getStatus());

        List<String> lstHeaderKeys = new List<String>();
        lstHeaderKeys.addAll(mapHeaders.keySet());
        System.assertEquals(lstHeaderKeys, oHttpResponse.getHeaderKeys());
    }

    /**
     * @description of the test: test the respond method of the service, with a multiple mock service, string as body
     * 2 requests will be sent to 1 mockservice with multiple services
     * Outcome: the correct response
     */
    @IsTest
    private static void test_ResponseWithString_MultipleRequest() {
        // setup your data
        Integer iStatusCode = 200;
        String sStatusMessage = 'OK';
        String sBodyMock1 = '{"test" : "message"}';
        String sBodyMock2 = '{"test mock service" : "message"}';
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};

        HttpRequest oRequest1 = new HttpRequest();
        oRequest1.setEndpoint('endpoint/resource1');

        HttpRequest oRequest2 = new HttpRequest();
        oRequest2.setEndpoint('endpoint/resource2');

        // perform the test
        Test.startTest();
        MockService oMockService = new MockService(new Map<String, MockService.CalloutMockService>{
                '.+resource1' => new MockService.CalloutMockService(iStatusCode, sStatusMessage, sBodyMock1, mapHeaders),
                '.+resource2' => new MockService.CalloutMockService(404, 'Not Found', sBodyMock2, mapHeaders)
        });
        HttpResponse oResponseMock1 = oMockService.respond(oRequest1);
        HttpResponse oResponseMock2 = oMockService.respond(oRequest2);
        Test.stopTest();

        // verify the result
        System.assertEquals(sBodyMock1, oResponseMock1.getBody());
        System.assertEquals(iStatusCode, oResponseMock1.getStatusCode());

        System.assertEquals(sBodyMock2, oResponseMock2.getBody());
        System.assertEquals(404, oResponseMock2.getStatusCode());
    }

    /**
     * @description of the test: test of the response, but the endpoint is not registered in the mock service
     * Outcome: the functionality needs to throw an exception
     */
    @IsTest
    private static void test_RespondWithString_Exception() {
        // setup your data
        Integer iStatusCode = 200;
        String sStatusMessage = 'OK';
        String sBodyMock1 = '{"test" : "message"}';
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};

        HttpRequest oRequest = new HttpRequest();
        oRequest.setEndpoint('/endpoint/resource1');
        // perform the test
        Test.startTest();
        MockService oMockService = new MockService(new Map<String, MockService.CalloutMockService>{
                'noEndpoint' => new MockService.CalloutMockService(iStatusCode, sStatusMessage, sBodyMock1, mapHeaders)
        });

        try {
            oMockService.respond(oRequest);
            System.assert(false);
        } catch (GlobalException ex){
            // verify the error
            System.assert(ex.getMessage().containsIgnoreCase(Label.MOCK_NOT_CONFIGURED));
            System.assert(ex.getMessage().containsIgnoreCase('/endpoint/resource1'));
        }

        Test.stopTest();
    }

    /**
     * @description of the test: test the mockservice with a blob
     * Outcome: a response with a blob
     */
    @IsTest
    private static void test_respondWithBlob() {
        // setup your data
        Integer iStatusCode = 200;
        String sStatusMessage = 'OK';
        Blob blBodyMock = Blob.valueOf('{"test" : "message"}');
        Map<String, String> mapHeaders = new Map<String, String>{'Content-Type' => 'application/json'};

        HttpRequest oRequest = new HttpRequest();
        oRequest.setEndpoint('endpoint/resource1');

        // perform the test
        Test.startTest();
        MockService oMockService = new MockService(new Map<String, MockService.CalloutMockService>{
                '.+resource1' => new MockService.CalloutMockService(iStatusCode, sStatusMessage, blBodyMock, mapHeaders)
        });

        HttpResponse oResponseMock = oMockService.respond(oRequest);
        Test.stopTest();

        // verify the result
        System.assertEquals(blBodyMock, oResponseMock.getBodyAsBlob());
    }

    /**
     * @description of the test: create a default calloutMockService
     * Outcome: a calloutMockservice with a pre-generated body, status and headers
     */
    @IsTest
    private static void test_DefaultMockConstructor() {
        // perform the test
        Test.startTest();
        MockService.CalloutMockService aSingleMockService = new MockService.CalloutMockService();
        Test.stopTest();

        // verify the result
        System.assertEquals(200, aSingleMockService.statusCode);
        System.assertEquals('OK', aSingleMockService.status);
    }
}