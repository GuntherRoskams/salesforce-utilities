/**
 * @Package: TestFactory.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: see MIT License
 * @Uses:
 *   - SchemaDescription.cls
 *   - TestObjectDefaults.cls
 *   - GlobalException.cls
 *
 * -------------------------------------------------------------------
 * Description: Framework class to create Test data for use in unit tests
 * First al all, you need to create a default description per object (your object has probably required fields). You can find an example in the class TestObjectDefaults.cls
 *
 * The class to define the defaults, needs to have the name Your_objectDefaults (like AccountDefaults or Custom_ObjectDefaults) A class for a custom object is the same as the API name of the object, without the __c extension.
 * Each class required to implement the interface FieldDefaults, and returns the field mapping to build the records of your object
 *
 * You have 2 possibilities to create your test records:
 *   - Insert 1 record in your database via the function TestFactory.createSObject(SObject, Boolean)
 *   - Insert a list of records in your database via the function TestFactory.createSObjectList(SObject, Integer, Boolean)
 *
 * To insert 1 record, you use the function TestFactory.createSObject(SObject, Boolean), where
 *   - the SObject is your object definition (if you define an SObject like new Account(), the functionality will get your mapping of the AccountDefaults class)
 *   - the Boolean gives you the possibility to insert this record into your database
 *
 * You can extend this function with a defaults class (another sub class where you define other defaults than your usual defaults).
 * In this class, you have the possibility to take over the fields from the main defaults class. You can use this as an extension of your regular object definition, or as a variant of your object.
 * Fi. AccountDefaults gives you the field name, the class PersonAccount can provide you an account with the field 'Name' and the recordtype 'PersonAccount'
 * If you want to use this extension, enable the class your function like TestFactory.createSObject(SObject, SpecificClass, Boolean)
 *
 * You can override the values of the fields during the tests. If a default value doesn't meet your requirements, you define the field in your object during the test
 *
 * To insert a list of records, you use the function TestFactory.createSObjectList(SObject, Integer, Boolean)
 * The same remarks here as in the single record creation function. You are able to enable an extra class
 *
 *
 * Created: 22/04/2020
 * Last Modified: 22/04/2020
 *
 * Unit tests:
 *
 * Changelog: 
 *
 */

public with sharing class TestFactory {
    
    /**
     * @description The name of your class, where you define your Object defaults
     */
    private final static String CLASS_OBJECT_DEFAULTS = 'TestObjectDefaults';
    
    /**
     * @description Basic functionality to create the object with the predefined defaults class
     * If you don't have the required subclass in your testobject defaults class, add this inner class into the file defined in the file with the name defined in the variable 'CLASS_OBJECT_DEFAULTS' (this is the name of the main class)
     *
     * @param oSObject the object created
     *
     * @return returns the object with the fields defined in your objectDefauls class
     */
    public static SObject createSObject(SObject oSObject){
        // check the type of object we are creating and add any defaults that are needed
        String sObjectName = String.valueOf(oSObject.getSObjectType());
        
        // construct the default values class. Due to the fact that Salesforce doesn't allow __ in a class name, we remove the __c from the name
        String sDefaultsClassName = sObjectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
        
        // if there is a class that exists for the default values, use this object description to create a record
        if (Type.forName(CLASS_OBJECT_DEFAULTS + '.' + sDefaultsClassName) != null){
            oSObject = createSObject(oSObject, sDefaultsClassName);
            return oSObject;
        } else {
            throw new GlobalException('DEFAULTS_CLASS_DOES_NOT_EXIST', GlobalUtils.repairPlaceHolders(Label.DEFAULTS_CLASS_DOES_NOT_EXIST, new Map<String, String>{'{0}' => sDefaultsClassName}));
        }
    }
    
    /**
     * @description Define an object with a given defaults class.
     * You can define different defaults classes per object (all with another default description of your object)
     *
     * @param oSObject theSObject created
     * @param sDefaultClassName the name of your defaults class, defined in the main class which is defined in your final static variable CLASS_OBJECT_DEFAULTS
     *
     * @return returns the object with the fields defined in your defaults class, given in the function.
     */
    public static SObject createSObject(SObject oSObject, String sDefaultClassName){
        // create an instance of the defaults class, so we can get the map of the field defaults
        Type t = Type.forName(CLASS_OBJECT_DEFAULTS + '.' + sDefaultClassName);
        if (t == null) {
            throw new GlobalException('DEFAULTS_CLASS_DOES_NOT_EXIST', GlobalUtils.repairPlaceHolders(Label.DEFAULTS_CLASS_DOES_NOT_EXIST, new Map<String, String>{'{0}' => sDefaultClassName}));
        }
        
        FieldDefaults theDefaults = (FieldDefaults) t.newInstance();
        addFieldDefaults(oSObject, theDefaults.getFieldDefaults());
        return oSObject;
    }
    
    /**
     * @description Creates a test record and adds it to the database
     *
     * @param oSObject the object created
     * @param bInsertIntoDB insert the object into the database (true) or not (false)
     *
     * @return the complete SObject, inserted into the database (also provided with the Salesforce unique recordId)
     */
    public static SObject createSObject(SObject oSObject, Boolean bInsertIntoDB){
        SObject theReturnObject = createSObject(oSObject);
        if (bInsertIntoDB){
            insert theReturnObject;
        }
        
        return theReturnObject;
    }
    
    /**
     * @description creates a test record, with the description of a custom defaults class, provided with the possibility to insert this record into the database
     *
     * @param oSObject the SObject created
     * @param sDefaultClassName the definition, which fields are included
     * @param bInsertIntoDB insert the record into the database (true) or not (false)
     *
     * @return the record, inserted into the database (also provided with the Salesforce unique recordId)
     */
    public static SObject createSObject(SObject oSObject, String sDefaultClassName, Boolean bInsertIntoDB){
        SObject theReturnObject = createSObject(oSObject, sDefaultClassName);
        if (bInsertIntoDB){
            insert theReturnObject;
        }
        return theReturnObject;
    }
    
    /**
     * @description Create a list of records, without inserting it into the database
     *
     * @param oSObject the definition of your object
     * @param iNumberOfRecords the number of records you want to create in the list
     *
     * @return a list of records
     */
    public static List<SObject> createSObjectList(SObject oSObject, Integer iNumberOfRecords){
        return createSObjectList(oSObject, iNumberOfRecords, null, false);
    }
    
    /**
     * @description Create al list of records, with or without inserting it into the database
     *
     * @param oSObject the definition of your object
     * @param iNumberOfRecords the number of records you want to create in the list
     * @param bInsertToDB insert into the database (true) or not (false)
     *
     * @return a list of records, inserted into the database (or not in case of false)
     */
    public static List<SObject> createSObjectList(SObject oSObject, Integer iNumberOfRecords, Boolean bInsertToDB){
        return createSObjectList(oSObject, iNumberOfRecords, null, bInsertToDB);
    }
    
    public static List<SObject> createSObjectList(SObject oSObject, Integer iNumberOfRecords, String sDefaultClassName, Boolean bInsertToDB){
        List<SObject> listRecordsToReturn = createSObjectList(oSObject, iNumberOfRecords, sDefaultClassName);
        if (bInsertToDB){
            insert listRecordsToReturn;
        }
        
        return listRecordsToReturn;
    }
    
    public static List<SObject> createSObjectList(SObject oSObject, Integer iNumberOfRecords, String sDefaultClassName){
        List<SObject> listRecordsToReturn = new List<SObject>();
        SObject oNewObject = null;
        
        // get one copy of the object
        if (sDefaultClassName == null){
            oNewObject = createSObject(oSObject);
        } else {
            oNewObject = createSObject(oSObject, sDefaultClassName);
        }
        
        Schema.SObjectField oNamefield = getNameField(oSObject);
        
        // Clone the object the number of times requested. Increment the name field so each record has a unique name
        for (Integer iIndex = 1; iIndex <= iNumberOfRecords; iIndex++){
            SObject oClonedObject = oNewObject.clone(false, true);
            if (! oNamefield.getDescribe().autoNumber){
                // the name field is not an autoNumber, we can add the name field in the object without any error
                oClonedObject.put(String.valueOf(oNamefield), (String) oClonedObject.get(oNamefield) + ' ' + String.valueOf(iIndex));
            }
            
            listRecordsToReturn.add(oClonedObject);
        }
        
        return listRecordsToReturn;
    }
    
    /**
     * @description This function combines the field values of specific classes with the field values of the default classes
     * If the field is located in both classes, the field value in the specific class overrides the value in the default class
     *
     * @param mapSpecificFields map with the specific field values
     * @param mapDefaultFields map with the default values
     *
     * @return a map with the complete combination of the 2 maps with field definitions
     */
    public static Map<Schema.SObjectField, Object> setSpecificFields(Map<Schema.SObjectField, Object> mapSpecificFields, Map<Schema.SObjectField, Object> mapDefaultFields){
        for (Schema.SObjectField aField : mapSpecificFields.keySet()){
            if (mapDefaultFields.get(aField) != null){
                mapDefaultFields.remove(aField);
            }
        }
        
        mapSpecificFields.putAll(mapDefaultFields);
        
        return mapSpecificFields;
    }
    
    /**
     * @description Replaces the empty field values in the object with the field values defined in the object defaults class
     *
     * @param oSObject the object created
     * @param mapDefaults the map with the field defaults, coming from the field defaults class
     */
    private static void addFieldDefaults(SObject oSObject, Map<Schema.SObjectField, Object> mapDefaults){
        // loop through the map of fields and if they weren't specifically assigned, fill them.
        Map<String, Object> mapPopulatedFields = oSObject.getPopulatedFieldsAsMap();
        for (Schema.SObjectField aField : mapDefaults.keySet()){
            if (! mapPopulatedFields.containsKey(String.valueOf(aField))){
                oSObject.put(aField, mapDefaults.get(aField));
            }
        }
    }
    
    /**
     * @description this function gets the name field of the Object the name of a record is required field.
     * For the account object can the Name-field be a different field. This is dependent on the recordtype of the object.
     * We cannot verify what 's the name field per record. This is a fixed setting in the object
     * If the organization is enabled for Person account, you will find 3 name fields on the account object:
     *  - Name: You cannot modify this value on Person account. This is a required field for account records which are not a Person Account (the recordtype is not 'PersonAccount')
     *  - LastName: you can modify this field, only when you define the recordtype 'PersonAccount' (is automatically enabled when the feature 'Person accounts' is enabled. This field is required when you create a Person account record
     *  - FirstName: a supplemantairy field to add the name of the account
     *
     * @param oSObject the object type you want to get the name field
     *
     * @return get the name field of the object
     */
    private static Schema.SObjectField getNameField(SObject oSObject){
        Schema.SObjectField oNameField = null;
        if (String.valueOf(oSObject.getSObjectType()) == 'Account'){
            /* For this object type, we need to get the recordtype of the record that we need to create
             * There is a difference in field between the recordtype 'PersonAccount' (when the feature Person Accounts is enabled) and the normal (Business) Account records
             * For Person account, the name field is 'LastName', for a business account, the name field is 'Name'
             */
            // Check if the feature 'Person Accounts' is enabled
            if (SchemaDescription.isPersonAccountsEnabled()){
                oNameField = oSObject.getSObjectType().getDescribe().fields.getMap().get('LastName');
            } else {
                oNameField = oSObject.getSObjectType().getDescribe().fields.getMap().get('Name');
            }
        } else {
            // for all the other objects, you have only 1 namefield. This can be get from the Schema Description
            SchemaDescription sd = new SchemaDescription(String.valueOf(oSObject.getSObjectType()));
            oNameField =  sd.getNameField();
        }
        
        return oNameField;
    }
    
    public interface FieldDefaults {
        Map<Schema.SObjectField, Object> getFieldDefaults();
    }
}