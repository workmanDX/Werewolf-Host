/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-19-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-16-2020   steven.workman@logmein.com   Initial Version
**/
trigger GamePlayerTrigger on Game_Player__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        // GamePlayerTriggerHelper.beforeInsert(Trigger.new);
    }
}