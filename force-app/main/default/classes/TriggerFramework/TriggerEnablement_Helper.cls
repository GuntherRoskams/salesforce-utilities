/**
 * @package: TriggerEnablement_Helper
 * @version 1.0
 * @copyright 2020 Forward
 * @uses Triggers.cls
 * @author Gunther Roskams
 *
 * @description Helper functionality for the triggerEnablement metadata object
 * With this object, the administrator can enable or disable trigger functionality in a declarative way (via Custom Metadata types / Trigger Enablement)
 * <p/>
 * <b>For the developer:</b> every time you want to create and enable a trigger, you need to add an entry per (sub)class that implements the Handler interface of the trigger framework
 * Enable the respective DML events, you want o enable the trigger. The trigger will fire in case of the DML event for that trigger functionality is activated
 * <p/>
 * <b>Unit tests:</b> the tests are triggered via a trigger, If you implement a trigger, this class is covered for 100%
 *
 * @date 02-05-2020
 * <p/>
 * <b>Changelog:</b>
 *
 */
public with sharing class TriggerEnablement_Helper {

    /**
     * @description Field mapping between the Trigger operations and the fields in the trigger enablement metadata object definition
     */
    private Map<System.TriggerOperation, Schema.SObjectField> mappingTriggerEvent = new Map<System.TriggerOperation, Schema.SObjectField>{
            TriggerOperation.BEFORE_INSERT => TriggerEnablement__mdt.BeforeInsert__c,
            TriggerOperation.BEFORE_UPDATE => TriggerEnablement__mdt.BeforeUpdate__c,
            TriggerOperation.BEFORE_DELETE => TriggerEnablement__mdt.BeforeDelete__c,
            TriggerOperation.AFTER_INSERT => TriggerEnablement__mdt.AfterInsert__c,
            TriggerOperation.AFTER_UPDATE => TriggerEnablement__mdt.AfterUpdate__c,
            TriggerOperation.AFTER_DELETE => TriggerEnablement__mdt.AfterDelete__c,
            TriggerOperation.AFTER_UNDELETE => TriggerEnablement__mdt.AfterUndelete__c
    };
    public Set<String> setEnabledTriggers {get; private set;}

    /**
     * @description selection of the active triggers, based on the operation type of the DML statement (before insert, after update,...)
     * We use a dynamic SOQL, due to check the different fields, dependent on the operation type
     *
     * @param oTriggerOperation the Trigger operation type, this reflects the DML statement before and after.
     */
    public TriggerEnablement_Helper(System.TriggerOperation oTriggerOperation){
        this.setEnabledTriggers = new Set<String>();
        String sQuery = 'SELECT Id, SupportingClass__c FROM TriggerEnablement__mdt WHERE ' + this.mappingTriggerEvent.get(oTriggerOperation) + ' = TRUE';
        List<TriggerEnablement__mdt> lstTriggerEnablements = new List<TriggerEnablement__mdt>();
        lstTriggerEnablements.addAll((List<TriggerEnablement__mdt>) Database.query(sQuery));

        if (lstTriggerEnablements.size() > 0){
            for (TriggerEnablement__mdt triggerEnablement : lstTriggerEnablements){
                Type tObjectType = Type.forName(triggerEnablement.SupportingClass__c);
                if (tObjectType != null){
                    Triggers.Handler theHandler = (Triggers.Handler) tObjectType.newInstance();
                    this.setEnabledTriggers.add(String.valueOf(theHandler));
                }
            }
        }
    }
}