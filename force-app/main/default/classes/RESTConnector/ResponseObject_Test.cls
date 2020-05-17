/**
 * @package ResponseObject
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses ResponseObject.cls, MockService.cls
 * @author Gunther Roskams
 *
 * @description unit tests to test the logic for the response object
 *
 * @date 06-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
@IsTest
private class ResponseObject_Test {

    /**
     * @description of the test: test the constructor of this object
     * Outcome: a valid responseObject
     */
    @IsTest
    private static void testConstructor() {
        HttpResponse oResponse = createTestResponse();

        Test.startTest();
        ResponseObject oResponseObject = new ResponseObject(oResponse);
        Test.stopTest();

        System.assertEquals(1, oResponseObject.mapResponseHeaders.size());
        System.assertEquals(oResponse.getBody(), oResponseObject.stringCompleteResponse);
        System.assertEquals(0, oResponseObject.listItems.size());
        System.assertEquals(oResponse.getStatus(), oResponseObject.responseStatusMessage);
        System.assertEquals(oResponse.getStatusCode(), oResponseObject.responseStatusCode);
    }

    private static HttpResponse createTestResponse(){
        String sBody = '{"message" : "This is a test message"}';
        Map<String, String> mapHeaders = new Map<String, String>{'Accept' => 'application/json'};

        // create a single mock response
        MockService.CalloutMockService oMock = new MockService.CalloutMockService(200, 'OK', sBody, mapHeaders);
        return oMock.respond(null);
    }
}