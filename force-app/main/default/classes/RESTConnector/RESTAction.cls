/**
 * @package RESTAction.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses GlobalException.cls
 * @author Gunther Roskams
 *
 * @description Generic definition of the callout action to an API. In this action, you will find:
 * <ul>
 *     <li>the HTTP method (like GET, POST, PUT, ...) </li>
 *     <li>a map with request headers, if you need to apply some request headers in your HTTP Request (fi. after authentication, it is possible to add the authorization header in your functional call)</li>
 *     <li>a return object. After your request, you will get a response with a response body. You can model this body in an object. In hat type of object needs your response body modelled ?</li>
 *     <li>the body of your request, this is designed as an object, due to the fact you can send a blob or a string (XML string or JSON string). If you want to send a string, you can serialize your object</li>
 *     <li>a name for the action. This name is used in the connector as well, to define your endpoint or other specific logic handling for this specific action. This is naame needs to be present in the connector attribute 'setPossibleActionNames'</li>
 * </ul>
 * <p/>
 * <b>Unit tests: </b>
 *
 * @date 03-05-2020
 * <p/>
 * <b>Changelog:</b> 
 *
 */
public virtual with sharing class RESTAction {

    /**
     * @description The default HTTP Request method for a connection to a REST API. If the developer didn't define a method in the action, the default method will be this value
     */
    @TestVisible
    private final String DEFAULT_HTTP_METHOD = 'GET';

    /**
     * @description The Salesforce Apex supported HTTP methods. PATCH is an HTTP Method, but is not default supported by Salesforce (without modification of the headers)
     * We add an extension to the endpoint like _HttpMethod=PATCH in the constructor, during the call
     */
    private final Set<String> setPossibleMethods = new Set<String>{
            'GET',
            'POST',
            'PUT',
            'DELETE',
            'PATCH'
    };

    /**
     * @description The desired HTTP method of your request.
     * This method is set via the constructor
     */
    public String HTTPMethod {get; private set;}

    /**
     * @description the map with headers you need to send with the request
     * This map with headers is set via the constructor
     */
    public Map<String, String> mapHeaders {get; private set;}

    /**
     * @description The body of your request, this can be a string or a blob
     * This body is set via the constructor
     */
    public Object body {get; private set;}

    /**
     * @description The return object, in which you want to collect your response body. This object is created in a separate class and is extended by the inner class 'ResponseObject.ResponseItem'
     * the name of this object is set via the constructor
     */
    public String returnObject {get; private set;}

    /**
     * @description The name of your action. This name should be in the set with possible action names in the connector for which you define this action.
     */
    public String name {get; private set;}

    /**
     * @description The constructor of the action to take by the connector to the API
     *
     * @param anHTTPMethod the HTTP method you want to use
     * @param mapWithHeaders the map with headers for your request
     * @param oBody the body of your request, this can be a String or a Blob
     * @param sReturnObject the return object to structure your response body
     * @param sName the name of your action
     */
    public RESTAction(String anHTTPMethod, Map<String, String> mapWithHeaders, Object oBody, String sReturnObject, String sName){
        this.HTTPMethod = checkRequestMethod(anHTTPMethod);
        this.mapHeaders = mapWithHeaders;
        this.body = oBody;
        this.returnObject = sReturnObject;
        this.name = sName;
    }

    /**
     * @description Helper method to verify the HTTP request method given.
     * If the method is not set in the action, we will initiate the default method
     *
     * @return the HTTP method used for the call
     */
    private String checkRequestMethod(String sMethodToCheck){
        String sFinalRequestMethod = this.DEFAULT_HTTP_METHOD;
        if (String.isNotBlank(sMethodToCheck)){
            String sCalloutMethod = sMethodToCheck.toUpperCase();
            if (this.setPossibleMethods.contains(sCalloutMethod)){
                sFinalRequestMethod = sCalloutMethod;
            } else {
                // throw an exception
                throw new GlobalException(GlobalUtils.repairPlaceHolders(Label.NOT_SUPPORTED_HTTP_METHOD, new Map<String, String>{'{0}' => sCalloutMethod}));
            }
        }

        return sFinalRequestMethod;
    }

}