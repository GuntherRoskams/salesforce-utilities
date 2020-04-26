# SchemaDescription
## License 
See MIT License in root folder

## Functionality
This class helps you to get on a fast way the full description of an object. You can get the fields of an object, the map with recordstypes of an object,...

Below the different possibilities of this class

## Constructor
**_public SchemaDescription(String)_**
Schema description for an object. The string represents the API Name of the object you want to get the description for.
```
SchemaDescription descAccount = new SchemaDescription('Account'); 
```

## Properties
**_public Schema.SObjectType objectType_**: the Schema.ObjectType from the object your requested in the constructor
```
SchemaDescription descAccount = new SchemaDescription('Account');
Schema.SObjectType SObjectAccount = descAccount.objectType;
```

## Methods
**_public Map<String, Schema.RecordTypeInfo> getMapRecordTypesByDeveloperName()_**: returns the map with the recordtypes for this object. Every objects has at least 1 recordtype (Master)
The index of the map is the Developername of the RecordType

```
SchemaDescription descAccount = new SchemaDescription('Account');
Map<String, Schema.RecordTypeInfo> mapRecTypesAccount = descAccount.getMapRecordTypesByDeveloperName();
```
**_public Schema.SObjectField getNameField()_**: returns the 1st field which is a name field. You can get the description of this field later on in another function (with a DescribeFieldResult object as return)
```
SchemaDescription descAccount = new SchemaDescription('Account');
Map<String, Schema.RecordTypeInfo> mapRecTypesAccount = descAccount.getNameField();
```

**_public Boolean SchemaDescription.isPersonAccountsEnabled()_**: returns if the Salesforce feature 'Person Accounts' is enabled.
```
Boolean bIsPersonAccountsEnabled = SchemaDescription.isPersonAccountsEnabled();
```