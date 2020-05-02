/**
 * @package Triggers
 * @version 1.0
 * @copyright 2020 Forward
 * @uses TriggerEnablement_Helper.cls
 * @author Gunther Roskams
 *
 * @description Trigger framework to handle triggers via class logic.
 * <p/>
 * Via this framework, you can group your trigger logic in 1 trigger, 1 supporting class (with the complete logic) and 1 unit test class for each SObject
 * Each class can have several inner classes (that implements the Handler interface) or you can implement all separate classes that implements the Handler interface.
 * <p/>
 * When you implement a trigger with logic, you need to enable a custom metadata type record in the custom metadata type 'TriggerEnablement' metadata Object.
 * In this record, you can choose to implement this trigger for each operation type.
 * <p/>
 * <b>Unit tests</b>: the tests are triggered via a trigger, If you implement a trigger, this class is covered for 100%
 *
 * @date 02-05-2020
 * <p/>
 * <b>Changelog:</b>
 *
 */
public with sharing class Triggers {

    private Map<System.TriggerOperation, List<Handler>> eventHandlerMapping = new Map<TriggerOperation, List<Handler>>();
    private Set<String> setActiveTriggers = new TriggerEnablement_Helper(Trigger.operationType).setEnabledTriggers;

    /**
     * @description the binding between the functionality that needs to be executed and the event when the functionality needs to be executed
     *
     * @param theEvent the trigger operation event when the functionality needs to be executed (this is a DML event, like fi. before insert, after update,...
     * @param triggerHandler the handler interface with the functionality that implements the handler interface in the class
     *
     * @return the full class with the mapping between the events and which logic needs to be executed
     */
    public Triggers bind(System.TriggerOperation theEvent, Handler triggerHandler){
        List<Handler> lstHandlers = eventHandlerMapping.get(theEvent);
        if (lstHandlers == null){
            lstHandlers = new List<Handler>();
        }

        if (this.setActiveTriggers.contains(String.valueOf(triggerHandler))){
            lstHandlers.add(triggerHandler);
            eventHandlerMapping.put(theEvent, lstHandlers);
        }

        return this;
    }

    /**
     * @description the execution of the logic in the trigger
     */
    public void manage(){
        List<Handler> lstHandlers = eventHandlerMapping.get(Trigger.operationType);

        if(lstHandlers != null && lstHandlers.size() > 0){
            for (Handler oFunctionality : lstHandlers){
                oFunctionality.handle();
            }
        }
    }

    /**
     * @description An interface to store the logic in a separate class (this class needs to implement this interface)
     */
    public interface Handler {
        void handle();
    }

}