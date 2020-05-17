# REST Connector
## License 
See MIT License in root folder

## Functionality
A basic virtual connector to connect Salesforce with a REST API. You are able to extend this connector by creating your own connector and extends your class with the class RESTConnector.cls
Beside this connector, you 'll find an Action class. This object is the collection of the details of your call:
 - the HTTP Method
 - the body (blob or string)
 - the headers
 - a return object: you are able to model your response body in an object where you extend the ResponseObject.ResponseItem class. More explanation later.
 - an action name: a name for your action, so you can define fi. another endpoint per call action (see also a different endpoint for authentication, where the name can be 'auth' and a service call, where the name can be 'service')
 
The connector works with Calloutparameters, which is an interface. In this interface, your need to implement the functions below:
 - String getEndpoint(): you can define your endpoint dependent of your action
 - String getTimeout(): this is a setting for the HTTP Request Timeout in milliseconds
 - Boolean getErrorHandling(): if you set this to true, you will get automatically an exception if the response has not the status code 2** (404, 500,...). If you set this to false, you need to write your error handling yourself.
 
The basic connector has the functionality to (and you don't to write it over and over again :-) ):
 - Collect the call details: Via the RESTAction, you can define every parameter for your HTTP Call. 
 You configure the endpoint and a custom timeout (default 10 seconds) in the Callout parameters. You can use the 'callout' method to define your endpoint via Remote Site Settings or Named Credentials (callout:Your_NamedCredential).
 - Prepare the HTTP Call: Dependent of the action, your call will be prepared with a string body, blob body, the type of the call (POST, GET, ...), modifications to your basic url via the connector
 - Execute the call: perform the callout and get the response in an object. In this object (which is the class ResponseObject), you will find the complete response body as a string, the map with response headers and your response, modeled as a list of objects. The type of the object is the object you defined in your action. This must be a class, extended by the virtual class ResponseObject.ResponseItem
 - Convert the response of your HTTP request into an object. Your object is from the type that you configured in your action object
 - Error handling: if you configure the callout parameter getErrorHandling() to true, you will receive by default an exception, if the callout throws an error. This is based on the response code. If the response has a status code other than 2**, you will receive the exception. If you configure this setting to false, you need to write your own error handling in the connector
 
 ## Setup
 The 3 classes you need to implement this framework are in this repository folder. Copy the classes and respective test classes into your org.
 
 Now it's time to create a connector for your API:
  - Create a class that implements the interface RESTConnector.CalloutParameters
  - implement your basic endpoint, timeout and if you want to implement the default exceptions for response statusses other than 2**, set the setting 'getErrorHandling' to true
  - Create a class to define your action that extends the class RESTAction
  
  ```
public class Google_GeocodingResponse extends ResponseObject.ResponseItem {

    public Double longitude {get; set;}
    public Double latitude {get; set;}
}
```
  
  - Define the constructor of this class
  
  ```
public class GoogleAction extends RESTAction {

    public GoogleAction(String aMethod, Map<String,String> mapWithHeaders, Object oBody, String sReturnObject, String theName){
        super(aMethod, mapWithHeaders,oBody,sReturnObject,theName);
    }
}
```
 - Define your response object by creating a class and extend this class by the class ResponseObject.ResponseItem
 - Define your main constructor with these 2 components by creating a class and extending this class by the virtual class RESTConnector
 ```
public class GoogleConnector extends RESTConnector {
    
    public GoogleConnector(GoogleAction oAction){
        super(new GoogleCalloutParams(), oAction);
        
        // these are your possible action names. You can use this to make a difference between the different types of calls (fi. to define your endpoint)
        this.setPossibleActionNames = new Set<String>{'geocode','directions'};
    }
}
```
 - implement your logic to construct your headers and body by override the function to your own logic. Basicly, the functions to create the headers and body are a simple take over from your action into the connector.
 - implement your logic to construct your return elements. Basicly, this function in the RESTConnector will convert the response (in case of status code 2**) into an object you provided in the action

Now you are able to use your connector by creating an instance of your action. Below a simple example, based on the code examples above:
```
/**
 * Create an instance of your action with the paramaters requested
 * The Http method: GET
 * The map with the headers: a map with the content-type header
 * The body: we don't provide a body, because we do a GET call with only URL parameters
 * The return object: Google_GeocodingResponse, the object we created earlier in this manual
 * the name of the action: geocode, one of the names in the connector property 'setPossibleActionNames'
 * 
GooleAction oAction = new GoogleAction('GET', new Map<String, String>{'Content-Type' : 'application/json'}, null, 'Google_GeocodingResponse', 'geocode');

// create an instance of the connector you created for your API
GoogleConnector oConnector = new GoogleConnector(oAction);

// add your parameters to the endpoint url
oConnector.endpoint += '<YOUR_PARAMETERS>';

// perform the callout and get the response in the object
ResponseObject oResponse = oConnector.callout();
```
The results of this code will provide you a responseObject with the following properties:
 - listItems: the list with your response items, this can be 1 result or more results. This depends from API to API
 - mapResponseHeaders: a map with all the headers in the response
 - stringCompleteResponse: a string with the complete response body (HttpResponse.getBody())
 - responseStatusCode: the response statuscode (200, 400, 404, 500,...)
 - responseStatusMessage: the response status message ('OK', 'Bad Request', 'Not found', 'Internal Server Error')
 
 ### Tips
 You can create a class with all the callouts for this connector. After that, you can use static methods to call your callout functionality in an easy way