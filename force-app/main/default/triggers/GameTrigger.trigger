/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-21-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-21-2020   steven.workman@logmein.com   Initial Version
**/
trigger GameTrigger on Game__c (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        // GameTriggerHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        GameTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}