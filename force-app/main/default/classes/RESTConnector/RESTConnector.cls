/**
 * @package RESTConnector.cls
 * @version 1.0
 * @Copyright 2020 Forward
 * @Uses RESTAction.cls, GlobalException.cls
 * @author Gunther Roskams
 *
 * @description Basis to create a connector to connect to a REST API
 * This class can be used as an extension for a connector between Salesforce and any API
 *
 * <p/>
 * <b>Unit tests: </b>
 *
 * @date 03-05-2020
 * <p/>
 * <b>Changelog:</b>
 *
 * Patch method
 * req.setHeader('X-HTTP-Method-Override','PATCH');
 * req.setMethod('POST');
 *
 */
public virtual with sharing class RESTConnector {

    /**
     * @description The callout parameters like your basic endpoint url , timeout,...)
     */
    public CalloutParameters calloutParameters {get; protected set;}

    /**
     * @description The endpoint of your API, for your request.
     * You are able to extend your endpoint with the parameters of a GET request
     */
    public String endpoint {get; set;}

    /**
     * @description The action to feed the connector and to build up the request of your API call
     * In this action, you will find:
     * <ul>
     *     <li>the HTTP Method</li>
     *     <li>the headers of your request</li>
     *     <li>the body of your request</li>
     *     <li>the return object to store and organize the response body of your request</li>
     *     <li>the name of your action. This name needs to be in the set with possible names (attribute in this connector)</li>
     * </ul>
     */
    public RESTAction action {get; private set;}

    /**
     * @description the set with the possible action names for the connector. You can define these names like you wish
     * Fi. A connector for the Google Maps API can contain the names 'geolocation' or 'directions'
     */
    @TestVisible
    public Set<String> setPossibleActionNames {get; protected set;}

    /**
     * @description the constructor of the connector. In this constructor, you need to define your callout parameters (which you can find in the interface) and the complete action.
     * After the definition of the constructor, you are able to modify the endpoint (with URL parameters)
     *
     * @param yourCalloutParameters the basic parameters for the callout. This is always a class or inner class that implements the interface 'RESTConnector.CalloutParameters'
     * @param aRestAction the action parameters for the callout (the method, your request headers, body,...)
     */
    public RESTConnector(CalloutParameters yourCalloutParameters, RESTAction aRestAction){
        this.calloutParameters = yourCalloutParameters;
        this.endpoint = yourCalloutParameters.getEndpoint();
        this.action = aRestAction;
    }

    /**
     * @description Method to construct the headers of your request
     * The headers will be defined in a map an will be converted into HTTP Headers when the HTTP Request is created and executed
     *
     * @return a map with the headers of your HTTP Request
     */
    public virtual Map<String, String> constructHeaders(){
        if (this.action.mapHeaders == null){
            return new Map<String, String>();
        }

        return this.action.mapHeaders;
    }

    public virtual Object constructBody(){
        if (this.action.body == null){
            return '';
        }

        return this.action.body;
    }

    /**
     * @description This method converts your HTTP response into a response object.
     * The response Object contains the flat string with the response, coming from the API, the response headers and an empty list with response items
     * The list with response items will be constructed in this method, and will be a list of the object type that is configured in the action
     *
     * @param aResponseMessage the response object that you receive from the callout (flat string with the response body and an empty list with records)
     *
     * @return the response object with the list of records, converted in the correct object type (which is configured in the action)
     */
    public virtual ResponseObject constructResponseObjects(ResponseObject aResponseMessage){
        if (String.isNotBlank(this.action.returnObject)){
            // we convert the flat string in the return object into the correct object records (from flat JSON text to your object)
            aResponseMessage.listItems = new List<ResponseObject.ResponseItem>();
            Type tObjectType = Type.forName(this.action.returnObject);
            if (tObjectType != null){
                // the apex object, configured in the action exists. We take this object type to convert the response into this type of object.
                ResponseObject.ResponseItem aResponseItem = (ResponseObject.ResponseItem) tObjectType.newInstance();
                aResponseItem = (ResponseObject.ResponseItem) JSON.deserialize(aResponseMessage.stringCompleteResponse, tObjectType);
                aResponseMessage.listItems.add(aResponseItem);
            } else {
                throw new GlobalException('APEXOBJECT_DOES_NOT_EXIST', GlobalUtils.repairPlaceHolders(Label.APEXOBJECT_DOES_NOT_EXIST, new Map<String, String>{'{0}' => this.action.returnObject}));
            }
        }

        return aResponseMessage;
    }

    /**
     * @description This method constructs your callout request, executes the callout and returns the object with your headers, the string with the response and the status code + message
     *
     * @return the response object with the response headers, the complete response body, the status code, the status message and the list with your response items (configured in your action)
     */
    public ResponseObject callout(){
        try {
            if (this.validateTheType()){
                Map<String, String> mapHeaders = this.constructHeaders();
                Object oRequestBody = this.constructBody();
                ResponseObject theResponse = this.doTheCallout(mapHeaders, oRequestBody);
                return this.constructResponseObjects(theResponse);
            }
        } catch (Exception ex){
            throw new GlobalException(ex.getMessage());
        }

        return null;
    }

    /**
     * @description Method to perform the callout, based on the headers and the body
     *
     * @param mapWithYourHeaders the map with the request headers
     * @param yourRequestBody the string or blob of your request
     *
     * @return the response object, without the conversion of the response items into the configured response object
     */
    private ResponseObject doTheCallout(Map<String, String> mapWithYourHeaders, Object yourRequestBody){
        ResponseObject theResponse = null;
        HttpRequest oHttpRequest = new HttpRequest();
        oHttpRequest.setTimeout(calloutParameters.getTimeout());
        if (mapWithYourHeaders.size() > 0){
            // convert the map into HTTP headers
            for (String sIndexHeader : mapWithYourHeaders.keySet()){
                oHttpRequest.setHeader(sIndexHeader, mapWithYourHeaders.get(sIndexHeader));
            }
        }
        oHttpRequest.setMethod(this.action.HTTPMethod);
        if (yourRequestBody instanceof String){
            String sBody = (String) yourRequestBody;
            if (String.isNotBlank(sBody)){
                oHttpRequest.setBody(sBody);
            }
        } else if (yourRequestBody instanceof Blob){
            Blob blBody = (Blob) yourRequestBody;
            oHttpRequest.setBodyAsBlob(blBody);
        }

        if (this.action.HTTPMethod == 'PATCH'){
            this.endpoint += '_HttpMethod=PATCH';
        }
        oHttpRequest.setEndpoint(this.endpoint);

        // perform the callout
        Http oHttp = new Http();

        HttpResponse oHttpResponse = new HttpResponse();

        try {
            oHttpResponse = oHttp.send(oHttpRequest);
            theResponse = new ResponseObject(oHttpResponse);
        } catch (CalloutException ex){
            throw new GlobalException('REST_CALLOUT_ERROR', 'Error during the callout: ' + ex.getMessage() + '(' + ex.getStackTraceString() + ')');
        }

        // if the configuration for the error handling is on, we provide a default error handling
        // there is no exception thrown by default if the status code is not a 2** response (like a 404 Not found)
        // we do this only if the callout parameters interface is asking that in the configuration.
        if (this.calloutParameters.getErrorHandling()){
            try {
                this.performErrorHandling(oHttpResponse);
                return theResponse;
            } catch (GlobalException ex){
                throw new GlobalException(ex.getMessage());
            }
        }

        return theResponse;
    }

    /**
     * @description this function handles of the error handling, if the response is not a 2** response (OK)
     * If the response code is not starting with a 2, an exception will be thrown with the http status code and status message
     * If you want to have the error from the response in the exception, write your own logic by overriding this method in your connector class.
     *
     * @param aResponse the raw response of an HTTP request
     */
    public virtual void performErrorHandling(HttpResponse aResponse){
        String sStatuscode = String.valueOf(aResponse.getStatusCode());
        if (! sStatuscode.startsWithIgnoreCase('2')){
            // this is not a correct response, we throw an error with the response code and message
            throw new GlobalException('ERR_CALLOUT', sStatuscode + ' - ' + aResponse.getStatus());
        }
    }

    /**
     * @description Validation of the type of the call. This will validate if your action name is in the set of allowed actions in the set of possible action names
     *
     * @return true if the action name is allowed, otherwise an exception
     */
    private Boolean validateTheType(){
        if (! this.setPossibleActionNames.contains(this.action.name)){
            String sNameClass = String.valueOf(this).split(':')[0];
            throw new GlobalException('ACTION_NOT_SUPPORTED', GlobalUtils.repairPlaceHolders(Label.ACTION_NOT_SUPPORTED, new Map<String, String>{
                    '{0}' => this.action.name,
                    '{1}' => sNameClass
            }));
        }

        return true;
    }

    /**
     * @description An interface to define your basic callout parameters
     * In this parameters, you will find:
     * <ul>
     *     <li>getEndpoint(): configure your endpoint to the API</li>
     *     <li>getTimeout(): configure the timeout in miliseconds</li>
     *     <li>
     *         getErrorHandling(): configure your basic error handling. If you return true, the connector will throw an exception when you receive an other response status as 2**
     *         If you return false, you need to foresee your own error handling during the callout
     *     </li>
     * </ul>
     */
    public interface CalloutParameters {
        String getEndpoint();
        Integer getTimeout();
        Boolean getErrorHandling();
    }

}