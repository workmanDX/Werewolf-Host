/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-05-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-03-2020   steven.workman@logmein.com   Initial Version
**/
global with sharing class GameAction {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String cardName { get; set; }
    @AuraEnabled
    global String setGameActivity { get; set; }
    @AuraEnabled
    global String actionDescription {get; set;}
    @AuraEnabled
    global String description {get; set;}

    global GameAction() {
    }

    global GameAction(Game_Activity__c action) {
        this.id = action.Id;
        this.cardName = action.Card_Name__c;
        this.setGameActivity = action.Set_Game_Activity__c;
        this.actionDescription = action.Game_Card__r.Character__r.Action_Description__c;
        this.description = action.Game_Card__r.Character__r.Description__c;
    }

    global static GameAction[] fromRecordList(
        Game_Activity__c[] records
    ) {
        GameAction[] actions = new GameAction[0];
        for (Game_Activity__c record : records) {
            actions.add(new GameAction(record));
        }
        return actions;
    }
}