/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-20-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
global with sharing class GamePlayer {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String name { get; set; }
    @AuraEnabled
    global String finalImage { get; set; }
    @AuraEnabled
    global String originalImage { get; set; }
    @AuraEnabled
    global Boolean killed { get; set; }
    @AuraEnabled
    global Boolean reveal { get; set; }
    @AuraEnabled
    global Decimal votesAgainst { get; set; }
    @AuraEnabled
    global Boolean voted {get; set;}
    @AuraEnabled
    global Boolean centerCard {get; set;}
    @AuraEnabled
    global String herokuFinalImage {get; set;}
    @AuraEnabled
    global String herokuOriginalImage {get; set;}
    @AuraEnabled
    global String description {get; set;}
    @AuraEnabled
    global String actionName {get; set;}


    global GamePlayer() {
    }

    global GamePlayer(Game_Player__c player) {
        this.id = player.Id;
        this.name = player.Name__c;
        this.finalImage = player.Final_Card_Image__c;
        this.originalImage = player.Original_Game_Card__r.Character__r.Image_URL__c;
        // this.herokuFinalImage = player.Final_Game_Card__r != null ? 'resources/images/characters/' + player.Final_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg' : null;
        // this.herokuOriginalImage = player.Original_Game_Card__r != null ? 'resources/images/characters/' + player.Original_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg' : null;
        this.herokuFinalImage = player.Final_Game_Card__r != null ? 'resources/images/characters/' + player.Final_Game_Card__r.Character__r.Name__c + '.png' : null;
        this.herokuOriginalImage = player.Original_Game_Card__r != null ? 'resources/images/characters/' + player.Original_Game_Card__r.Character__r.Name__c + '.png' : null;
        this.killed = player.Killed__c;
        this.reveal = player.Reveal__c;
        this.votesAgainst = player.Votes_Against__c;
        this.voted = player.Voted_For__c != null ? true : false;
        this.centerCard = player.Center_Player__c;
        this.description = player.Original_Game_Card__r.Character__r.Description__c?.replaceAll('<[^>]+>',' ');
        this.actionName = player.Original_Game_Card__r.Character__r.Name__c;
    }

    global static GamePlayer[] fromRecordList(
        Game_Player__c[] records
    ) {
        GamePlayer[] players = new GamePlayer[0];
        for (Game_Player__c record : records) {
            players.add(new GamePlayer(record));
        }
        return players;
    }
}