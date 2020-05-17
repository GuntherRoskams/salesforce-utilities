/**
 * @package ResponseObject.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses 
 * @author Gunther Roskams
 *
 * @description The definition of the response object.
 * In this object, you will find the full response of the outbound call. This means:
 * <ul>
 * <li>the headers in a structured way</li>
 * <li>the body. You can cast the body in your own object, the inner class ResponseItem is a generic object that you can use to extend for your own Response object</li>
 * <li>the status code</li>
 * <li>the status message</li>
 * </ul>
 * <p/>
 * <b>Unit tests: </b> ResponseObject_Test.cls
 *
 * @date 03-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
public with sharing class ResponseObject {

    /**
     * @description the headers that you receive in the response from your HTTP request
     */
    public Map<String, String> mapResponseHeaders {get; set;}

    /**
     * @description the string with the complete response body that you receive after your HTTP Request
     */
    public String stringCompleteResponse {get; set;}

    /**
     * @description the HTTP Response status code (the codes like described here: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes)
     */
    public Integer responseStatusCode {get; set;}

    /**
     * @description The HTTP Response status message, dependent of the HTTP Response status code
     */
    public String responseStatusMessage {get; set;}

    /**
     * @description the list with items in your response. This item can be your own defined response object, extended by the virtual class ResponseItem.
     */
    public List<ResponseItem> listItems {get; set;}

    /**
     * @description the constructor of the Response object, based on an HTTP Response that you receive after an HTTP Request
     *
     * @param anHttpResponse the response that you receive after an HTTP Request
     */
    public ResponseObject(HttpResponse anHttpResponse){
        this.mapResponseHeaders = collectHeadersFromResponse(anHttpResponse);
        this.stringCompleteResponse = anHttpResponse.getBody();
        this.listItems = new List<ResponseItem>();
        this.responseStatusCode = anHttpResponse.getStatusCode();
        this.responseStatusMessage = anHttpResponse.getStatus();
    }

    /**
     * @description Collect the headers from the HTTP Response.
     * Since we have no functionality to get the headers in 1 function (like HTTPResponse.getHeaders()), we use 2 functions to get all the headers from the response
     * HTTPResponse.getHeaderKeys() to get all the header keys (like Content-Type, Authorization,...)
     * HTTPResponse.getHeader(String) to get the content in the header, based on the key
     *
     * @param anHttpResponse the response that you receive after an HTTP request
     *
     * @return map with the headers, collected from the HTTP Response
     */
    private Map<String, String> collectHeadersFromResponse(HttpResponse anHttpResponse){
        Map<String, String> mapHeaders = new Map<String, String>();

        List<String> lstHeaderKeys = anHttpResponse.getHeaderKeys();
        if (lstHeaderKeys != null && lstHeaderKeys.size() > 0){
            for (String sHeaderKey : lstHeaderKeys){
                mapHeaders.put(sHeaderKey, anHttpResponse.getHeader(sHeaderKey));
            }
        }

        return mapHeaders;
    }

    public virtual class ResponseItem {}
}