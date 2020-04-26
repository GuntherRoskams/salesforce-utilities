# TestFactory Framework

## License 
See MIT License in root folder

## Description
The code in this directory provides you a framework to create testdata for Unit tests in Apex (Salesforce.com). 
You can create testdata from each standard object and custom object that you need in your unit tests.

This framework contains 2 important files:
 * TestObjectDefaults.cls: this is the class where you define your default field values per object (for each object a Defaults class, and per object description a separate class)
 * TestFactory.cls: this is the class with the master functionality to create the testdata
  
### TestObjectDefaults.cls
In this class, you need to define your defaults per object (you want to create test data for) and per type of record. You define this defaults via an inner class that implements the interface _TestFactory.FieldDefaults_.
For each SObject you want to create test data for, you need to create a Defaults class. The name of this class is the API Name of your object + Defaults. If you create a custom object, you need to leave the __c (due to it is not allowed to create a custom class with 2 underscores in the name)

```
public class AccountDefaults implements TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
        return new Map<SObjectField, Object>{
                Account.Name => 'TestAccount'
        };
    }
}
```
You can choose the name of your specific classes. If you want to define a specific recordtype of an account (like a Person Account), you can create an inner class to define the specific. 
Best practise is here to use the defaults class and extend this one with more (or other) field values, unless you want to create a whole new type (like a Person Account)

In the example below, I use the AccountDefaults in combination with new Field values. The account that is generated with the function

```
Account a = (Account) TestFactory.createSObject(new Account(), 'EngineeringAccount');
```

will be an account with the follwing fields:
  * Name: TestAccount (coming from the AccountDefaults)
  * Industry: Engineering (coming from the Engineering defaults below)

```
public class EngineeringAccount implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            Map<Schema.SObjectField, Object> defaultMapping = new AccountDefaults().getMappingDefaultValues();
            Map<Schema.SObjectField, Object> specificMapping = new Map<SObjectField, Object>{
                    Account.Industry => 'Engineering'
            };
            
            return TestFactory.setSpecificFields(specificMapping, defaultMapping);
        }
    }
```

### Testfactory.cls
This class provides the functionality to create your test data in test classes and unit tests. You have the possibility to create 1 single record or a list of records, you can insert the data in your database, and can define you own defaults (dependent of your required fields or validation rules)
Below the different functions to create your data:
 * **public SObject createSObject(SObject)**: you create an SObject with the ObjectDefaults, defined in your TestObjectDefaults class
 ```
Account a1 = (Account) TestFactory.createSObject(new Account());

// this account has the default fields defined + the fields who are defined in the function. The values in this function override the values in your defaults (if defined in the defaults)
Account a2 = (Account) TestFactory.createSObject(new Account(AccountNumber = 'G-1234'));
 ```
 * **public SObject createSObject(SObject, String)**: you create an SObject with the defaults of the specified class you defined in the String. If you didn't define the class in your TestObjectDefaults, you will receive an exception while creating the record
 ```
 Account a = (Account) TestFactory.createSObject(new Account(), 'AccountSpecified');
 ```
 * **public SObject createSObject(SObject, Boolean)**: you create an SObject with the ObjectDefaults, defined in your TestObjectDefaults class and you have the possibility to insert the record into your database via the Boolean
   * Boolean true: insert the records into your database and receive the Id
   * Boolean false: don't insert the record into your database
 ```
 Account a = (Account) TestFactory.createSObject(new Account(), true);
 ```
 * **public SObject createSObject(SObject, String, Boolean)**: you create an SObject with the defaults of the specified class you defined in the String and you can insert the record into your database
 ```
 Account a = (Account) TestFactory.createSObject(new Account(), 'AccountSpecific', true);
 ```
 * **public List&lt;SObject&gt; createSObjectList(SObject, Integer)**: you create a list with SObjects. The list contains the number of objects that you provide in the integer. The default definition of your object is located in the TestObjectDefaults class, in the subclass of the objectDefaults. The name of the object is increased with the number of your created record. In the following example, the code creates 5 accounts with the Name, which is defined in the defaults class and is extended with a space and 1,2,3,4 or 5
  ```
  List<Account> lstAccounts = (List<Account>) TestFactory.createSObjectList(new Account(), 5);
  ```
 * **public List&lt;SObject&gt; createSObjectList(SObject, Integer, String)**: you create a list with SObjects. The list contains the number of objects that you provide in the integer. The defaults values of your object is located in the specific class with the name that you defined in the string.
  ```
  List<Account> lstAccounts = (List<Account>) TestFactory.createSObjectList(new Account(), 5, 'AccountSpecific');
  ```
 * **public List&lt;SObject&gt; createSObjectList(SObject, Integer, Boolean)**: you create a list with SObjects. The list contains the number of objects that you provide in the integer. The default definition of your object is located in the TestObjectDefaults class, in the subclass of the objectDefaults. And you have the possibility to insert your records in the database:
   * Boolean true: insert the records into your database and receive the Id
   * Boolean false: don't insert the record into your database
  ```
  List<Account> lstAccounts = (List<Account>) TestFactory.createSObjectList(new Account(), 5, true);
  ```
  * **public List&lt;SObject&gt; createSObjectList(SObject, Integer, String, Boolean)**: You create a list with SObjects. The list contains the number of objects that you provide in the integer. The defaults values of your object is located in the specific class with the name that you defined in the string and you have the possibility to add the records into your database
  ```
  List<Account> lstAccounts = (List<Account>) TestFactory.createSObjectList(new Account(), 5, 'AccountSpecific', true);
  ```
##Installation
The 2 classes contain logic from the classes GlobalUtils and GlobalException. You need to install these as first or toghether with the 2 classes, mentioned at the top of this document
