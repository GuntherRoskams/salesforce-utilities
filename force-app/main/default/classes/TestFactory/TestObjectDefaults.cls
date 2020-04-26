/**
 * @Package: TestObjectDefaults.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: See MIT License
 * @Uses: TestFactory.cls, GlobalUtils.cls
 *
 * -------------------------------------------------------------------
 * Description: Default definitions per object, to create (test) records.
 * The default field values for the objects are defined as a class with the name <DeveloperNameOfTheOject> + 'Defaults' (fi. AccountDefaults)
 * For a custom SObject, you skip the __c, due to the fact that __ is not allowed in a class name (fi the SOBject 'Custom_Object__c' gets the class 'Custom_ObjectDefaults'
 * Specific classes can be named like you wish, but we recommend a name that you can recognize the object and the type of records you want to create with these defaults
 *
 * Created: 25/04/2020
 * Last Modified: 25/04/2020
 *
 * Unit tests:
 *
 * Changelog: 
 *
 */

public with sharing class TestObjectDefaults {
    
    public static Map<String, Profile> mapProfiles = GlobalUtils.getMapProfilesByName();
    
    /**
     * @description Default values for an Account record
     */
    public class AccountDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            return new Map<SObjectField, Object>{
                    Account.Name => 'TestAccount'
            };
        }
    }
    
    /**
     * @description Default values for an Account record, when you specify the class 'AccountSpecific' in the function
     */
    public class AccountSpecific implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            Map<Schema.SObjectField, Object> defaultMapping = new AccountDefaults().getMappingDefaultValues();
            Map<Schema.SObjectField, Object> specificMapping = new Map<SObjectField, Object>{
                    Account.Name => 'My Test Account'
            };
            
            return TestFactory.setSpecificFields(specificMapping, defaultMapping);
        }
    }
    
    public class UserDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            return new Map<SObjectField, Object>{
                    User.FirstName => 'Testy',
                    User.LastName => 'the Tester',
                    User.Alias => 'TestUser',
                    User.Email => 'testuser@tester.com',
                    User.EmailEncodingKey => 'UTF-8',
                    User.LanguageLocaleKey => 'en_US',
                    User.LocaleSidKey => 'en_US',
                    User.TimezoneSidKey => 'Europe/Brussels',
                    User.Username => 'testy.tester@unit-test.com',
                    User.ProfileId => mapProfiles.get('Standard User').Id
            };
        }
    }
    
    public class ContactDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            return new Map<Schema.SObjectField, Object>{
                    Contact.LastName => 'Testcontact'
            };
        }
    }
    
    public class CaseDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            return new Map<Schema.SObjectField, Object>{
                    Case.Subject => 'Test Case'
            };
        }
    }
    
    public class LeadDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            return new Map<Schema.SObjectField, Object>{
                    // both required fields in the object Lead
                    Lead.LastName => 'Test Lead',
                    Lead.Company => 'Test Company'
            };
        }
    }
    
    public class OpportunityDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getMappingDefaultValues(){
            return new Map<Schema.SObjectField, Object>{
                    // all fields below are required in the object Opportunity
                    Opportunity.Name => 'Test Opportunity',
                    Opportunity.StageName => 'ClosedWon',
                    Opportunity.CloseDate => Date.today()
            };
        }
    }
}