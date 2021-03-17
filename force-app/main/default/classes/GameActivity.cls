/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-20-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-10-2020   steven.workman@logmein.com   Initial Version
**/
global with sharing class GameActivity {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String playerName { get; set; }
    @AuraEnabled
    global String playerId { get; set; }
    @AuraEnabled
    global String actionName { get; set; }
    @AuraEnabled
    global Boolean allowFlip { get; set; }
    @AuraEnabled
    global Boolean showPlayers { get; set; }
    @AuraEnabled
    global Boolean showUnassigned { get; set; }
    @AuraEnabled
    global Boolean showPlayer { get; set; }
    @AuraEnabled
    global Boolean allowSelection { get; set; }
    @AuraEnabled
    global Integer actionCount { get; set; }
    @AuraEnabled
    global Integer actionCountMax { get; set; }
    @AuraEnabled
    global Integer centerPlayerActionCountMax { get; set; }    
    @AuraEnabled
    global Map<String, Player> players {get; set;}
    @AuraEnabled
    global Map<String, Player> centerPlayers {get; set;}

    global GameActivity() {
    }

    global GameActivity(Game_Activity__c activity) {
        this.id = activity.Id;
        this.playerName = activity.Game_Player__r.Name__c;
        this.actionName = activity.Card_Name__c != null ? activity.Card_Name__c : 'Voting';
        this.playerId = activity.Game_Player__r.Name;
    }

    global static GameActivity[] fromRecordList(
        Game_Activity__c[] records
    ) {
        GameActivity[] activity = new GameActivity[0];
        for (Game_Activity__c record : records) {
            activity.add(new GameActivity(record));
        }
        return activity;
    }

    global class player{
        @AuraEnabled
        global String name { get; set; }
        @AuraEnabled
        global String playerId { get; set; }
        @AuraEnabled
        global String characterName { get; set; }
        @AuraEnabled
        global Boolean showCharacter {get; set;}
        @AuraEnabled
        global Boolean allowFlip {get; set;}
        @AuraEnabled
        global Boolean centerPlayer {get; set;}
        @AuraEnabled
        global String characterImage {get; set;}
        @AuraEnabled
        global String finalCharacterName {get; set;}
        @AuraEnabled
        global String finalCharacterImage {get; set;}
    }
}