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
    
    /**
     * @description This function gets the fields of the object
     *
     * @return map with the fields of an object.
     */
    public Map<String, Schema.SObjectField> getMapFieldsObject(){
        return this.objectType.getDescribe().fields.getMap();
    }
    
    /**
     * @description This function gets the namefield of the object
     *
     * @return the SObject field of the object
     */
    public Schema.SObjectField getNameField(){
        Map<String, Schema.SObjectField> mapFieldsObject = this.getMapFieldsObject();
        // loop through the fields and check the isNameField() function. If the field is a name field, we return this field
        for (Schema.SObjectField aField : mapFieldsObject.values()){
            Boolean bIsNameField = aField.getDescribe().isNameField();
            if (bIsNameField){
                return aField;
            }
        }
        
        // this scenario should not be possible, but we need to cover it programmatically
        return null;
    }
    
    /**
     * @description detects the feature Person Accounts
     *
     * @return returns if the feature 'Person Accounts' is enabled or not
     */
    public static Boolean isPersonAccountsEnabled(){
        
        Map<String, Schema.RecordTypeInfo> mapRecordtypes = new SchemaDescription('Account').getMapRecordTypesByDeveloperName();
        if (mapRecordtypes.get('PersonAccount') != null){
            return true;
        }
        
        return false;
    }

}