# Trigger Framework
## License
See MIT License in root folder

## Functionality
This trigger framework allows you:
 - Create your trigger logic in a structured way
 - Enable / disable the trigger logic via a declarative way, you enable or disable the respective Trigger operation type in the custom metadata type 'Trigger Enablement'

## Installation
Copy the object TriggerEnablement__mdt to your org, using the Metadata API, or create the custom metadata object like you create any other object. You need to keep the APINames of the fields. If you use Visual Studio Code or IntelliJ with Illuminated Cloud, you can copy and paste the files from the directory 'Objects/TriggerEnablement__mdt' from this repository into your org directory (and deploy the metadata).

After the installation of your object, copy the classes in this directory into your org. You can do it manually, or you can do it in the same way you copied the metadata type.

Now, you have the framework, let's go create a trigger with this framework. 
### Create the supporting class
One of the best practises of writing triggers is to separate your trigger logic from your trigger. Write the logic in a separate class. From the trigger, call the class functionality in your trigger.

This framework support 2 ways of implementing your triggers:
 - Create 1 supporting class for each SObject. This class contains one or more inner classes that implements the interface Triggers.Handler, to separate different logic for the same SObject
 - Create 1 class per logic, implement the interface Triggers.Handler in each class you want to use as a trigger logic
 
```
// 1 class for each SObject, several inner classes to support the different logic for 1 SObject
public with sharing class Account_TriggerHandler {
    
    public with sharing class TriggerLogic1 implements Triggers.Handler {
        // required function to handle your trigger logic
        public void handle(){
            // add your logic here
        }
    }
}

// several classes to support 1 SObject
public with sharing class Account_TriggerLogic1 implements Triggers.Handler {
    // required function to handle your trigger logic
    public void handle(){
        //add your logic here
    }
}

public with sharing class Account_TriggerLogic2 implements Triggers.Handler {
    // required function to handle your trigger logic
    public void handle(){
        //add your logic here
    }
}
```
### Create the trigger
We create the bases skeleton from a trigger like before:
```
trigger <NAME_OF_YOUR_TRIGGER> on <YOUR_SOBJECT> (TRIGGER_OPERATIONS) {

}
```
So you get the following trigger basic skeleton for an account
```
trigger Account_Trigger on Account (before insert, after update) {

}
```
In this skeleton, we add the calls to our trigger logic. You need to call the logic separate for EACH operationtype, you want to execute the logic
We start to call our framework and bind the logic from our class (which implements our interface) to the operation type of the trigger
```
trigger Account_Trigger on Account (before insert, after update) {
    new Triggers()
        // if you use a separate class for each logic, you can call the logic like this way
        .bind(TriggerOperation.BEFORE_INSERT, new Account_Logic())
        // if you use 1 class for all the logic with inner classes, you can call the logic like this
        .bind(TriggerOperation.BEFORE_INSERT, new Account_TriggerHandler.Logic1())
        .bind(TriggerOperation.AFTER_INSERT, new Account_TriggerHandler.Logic2())
        .bind(TriggerOperation.AFTER_UPDATE, new Account_TriggerHandler.Logic2())
        // execute the logic with the manage function of the framework
        .manage();
}
```
Nothing more, nothing less. You wrote 1 extendable trigger, with logic in separate classes or inner classes. Now it is time to enable your triggers. By default, your trigger logic is not enabled !!
### Enable your trigger logic
Enabling the trigger logic can be done by the custom metadata type 'Trigger Enablement'. For each trigger logic, you need to create a new record in the custom metadata type 'Trigger Enablement'. For the trigger that we created above, we enable the trigger with creating a record like this:
 - Go to the Custom metadata types in the Setup menu
 - Click on the link 'Manage records' next to the custom metadata type 'Trigger Enablement'
 - Click to the button 'New' and add a new record:
   - Name: you can choose a name by yourself. Best practise is to give your record a name that you can recognize which logic you will enable (I take always the name of the SObject, and the (sub)class of the logic)
   - Supporting Class: this is the complete class name. If you use an inner class, you need to put the name of the class and the inner class in this field (fi. Account_TriggerHandler.Logic1)
   - Check the boxes for the trigger operation types when you want to enable your trigger logic.
     Lookout: if you check the box, you also need to bind this operation type with the logic class in your trigger.
  - Save the record. Your trigger logic is now enabled.
 
 # Write unit tests for your trigger logic
 Unnecessary to mention, but you need to write tests for your Apex classes, so you need to write tests for your trigger logic. It is usual business.
 If you wrote the tests for your trigger, both classes of the framework are covered for 100%