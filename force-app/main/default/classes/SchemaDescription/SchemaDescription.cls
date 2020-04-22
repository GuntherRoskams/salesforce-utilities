/**
 * @Package: SchemaDescription.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: See MIT License
 * @Uses: 
 *
 * -------------------------------------------------------------------
 * Description: Object and Field Description, dependent on the object and/or field
 *
 * SchemaDescription(String): object description
 * SchemaDescription(String, String): field description
 *
 * Created: 19/04/2020
 * Last Modified: 19/04/2020
 *
 * Unit tests:
 *
 * Changelog: 
 *
 */

public with sharing class SchemaDescription {
    
    public Schema.SObjectType objectType {get; private set;}
    
    private final Map<String, SObjectType> mapSchemaObjects = Schema.getGlobalDescribe();
    
    /**
     * @description Constructor of a schema description, to get the description of an object
     *
     * @param sSObjectAPIName the API Name of the SObject requested
     */
    public SchemaDescription(String sSObjectAPIName){
        this.objectType = getSchemaObjectType(sSObjectAPIName);
    }
    
    
    /**
     * @description Get the shema description of an SObject, based on the API name of an object
     *
     * @param sSObjectAPIName The API Name of the object requested
     *
     * @return the Schema.SObjectType of the object requested. If the object requested is a non-existing SObject, the function will throw an exception
     */
    private Schema.SObjectType getSchemaObjectType(String sSObjectAPIName){
        if (String.isBlank(sSObjectAPIName)){
            throw new GlobalException().throwObjectException();
        }
        
        Schema.SObjectType oObjectType = this.mapSchemaObjects.get(sSObjectAPIName);
        if (oObjectType == null){
            throw new GlobalException().throwObjectException(sSObjectAPIName);
        }
        
        return oObjectType;
    }
    
    /**
     * @description Get the recordtypes from the SObject defined in the constructor
     *
     * @return a map with the recordtypes of the object. The API name of the recordtype is the index, the Recordtype info is the value in the map
     */
    public Map<String, Schema.RecordTypeInfo> getMapRecordTypesByDeveloperName(){
        return this.objectType.getDescribe().getRecordTypeInfosByDeveloperName();
    }

}