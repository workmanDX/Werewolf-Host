/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 03-16-2021
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
global with sharing class GameInfo {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String stage { get; set; }
    @AuraEnabled
    global String cardBack { get; set; }
    @AuraEnabled
    global String herokuCardBack { get; set; }
    @AuraEnabled
    global String action { get; set; }

    global GameInfo() {
    }

    global GameInfo(Game__c game) {
        this.id = game.Id;
        this.stage = game.Stage__c;
        this.cardBack = game.Card_Back_Image__c;
        this.herokuCardBack = 'resources/images/cardbacks/default.png';
        this.action = game.Activity__c;
    }
}