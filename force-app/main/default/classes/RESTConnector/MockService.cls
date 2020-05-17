/**
 * @package MockService.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses GlobalException.cls
 * @author Gunther Roskams
 *
 * @description service to generate callout mock responses to use in unit tests
 * You can create a Mock response for a single response, or a multiple response (like a custom authentication and a service call)
 * You can create a Mock service like the code below:
 * <p/><p/>
 * <i>MockService aMock = new MockService();</i><p/>
 * <i>aMock.registerCalloutMockService('.+auth.+', new MockService.CalloutService(200, 'OK', '{"test" : "test"}', new Map<String, String>{'Accept' => 'application/json'});</i>
 * <p/><p/>
 * If you register more calloutServices, you are able to test 1 full process with multiple callout processes
 * <p>
 *
 * <b>Unit tests: </b>
 *
 * @date 06-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
public with sharing class MockService implements HttpCalloutMock{

    /**
     * @description the map with one or more mock services
     */
    public Map<String, CalloutMockService> mapMockServices {get; private set;}

    /**
     * @description The constructor to create one or more mock services
     */
    public MockService(){
        this.mapMockServices = new Map<String, MockService.CalloutMockService>();
    }

    public MockService(Map<String, CalloutMockService> mapServices){
        this.mapMockServices = mapServices;
    }

    /**
     * @description Register the callout mock service into your map.
     *
     * @param sRegex regular expression to recognize your endpoint or resource
     * @param oMock the mock response for this endpoint
     */
    public void registerCalloutMockService(String sRegex, CalloutMockService oMock){
        this.mapMockServices.put(sRegex, oMock);
    }

    /**
     * @description the collection of responses for the several requests
     *
     * @param oRequest the HTTP Request that will be forwarded to the specific callout mock service
     *
     * @return the mock service needed for your request
     */
    public HttpResponse respond(HttpRequest oRequest){
        CalloutMockService aMockService;
        for (String sEndpointReqex : this.mapMockServices.keySet()){
            if (Pattern.matches(sEndpointReqex, oRequest.getEndpoint())){
                aMockService = this.mapMockServices.get(sEndpointReqex);
                break;
            }
        }

        if (aMockService != null){
            return aMockService.respond(oRequest);
        }

        throw new GlobalException(Label.MOCK_NOT_CONFIGURED + oRequest.getEndpoint());
    }

    /**
     * @description One specific Callout mock service, used in the multiple service MockService
     */
    public class CalloutMockService implements HttpCalloutMock {

        /**
         * @description The status code of the response like 200, 404, 500,...
         */
        public Integer statusCode {get; set;}

        /**
         * @description The status message, dependent on the status code (like OK, NOT FOUND,...)
         */
        public String status {get; set;}

        /**
         * @description the body of your response. This can be a blob or a (JSON)string
         */
        public Object body {get; set;}

        /**
         * @description the map with your response headers
         */
        public Map<String, String> responseHeaders {get; set;}

        /**
         * @description Constructor with a default response
         */
        public CalloutMockService(){
            this.statusCode = 200;
            this.status = 'OK';
            this.body = '{"message" : "this is a test response"}';
            this.responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        }

        /**
         * @description create a mock response with a string body
         *
         * @param iStatusCode the HTTP Status code (200, 404, 500,...)
         * @param sStatus the HTTP status message
         * @param sBody the body as a string
         * @param mapResponseHeaders the map with response headers
         */
        public CalloutMockService(Integer iStatusCode, String sStatus, String sBody, Map<String,String> mapResponseHeaders){
            this.statusCode = iStatusCode;
            this.status = sStatus;
            this.body = sBody;
            this.responseHeaders = mapResponseHeaders;
        }

        /**
         * @description create a mock response with a blob as body
         *
         * @param iStatusCode the HTTP status code (200, 404, 500,...)
         * @param sStatus the HTTP Status message
         * @param blBody the body as a blob
         * @param mapResponseHeaders the map with response headers
         */
        public CalloutMockService(Integer iStatusCode, String sStatus, Blob blBody, Map<String, String> mapResponseHeaders){
            this.statusCode = iStatusCode;
            this.status = sStatus;
            this.body = blBody;
            this.responseHeaders = mapResponseHeaders;
        }

        /**
         * @description generate a single http response
         *
         * @param oRequest the request to simulate your response
         *
         * @return your http response record
         */
        public HttpResponse respond(HttpRequest oRequest){
            HttpResponse oResponse = new HttpResponse();
            oResponse.setStatusCode(this.statusCode);
            oResponse.setStatus(this.status);

            // add the body to your response
            if (this.body instanceof String){
                oResponse.setBody((String) this.body);
            } else if (this.body instanceof Blob){
                oResponse.setBodyAsBlob((Blob) this.body);
            }

            // add the headers to your response
            if (this.responseHeaders != null && this.responseHeaders.size() > 0){
                for (String sIndex : this.responseHeaders.keySet()){
                    oResponse.setHeader(sIndex, this.responseHeaders.get(sIndex));
                }
            }

            return oResponse;
        }
    }
}