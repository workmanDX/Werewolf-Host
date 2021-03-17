/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-14-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
global with sharing class GameSettings {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String playerAppUrl { get; set; }
    @AuraEnabled
    global String playerAppUrlMinified { get; set; }
    @AuraEnabled
    global String gameApiKey { get; set; }

    global GameSettings() {
    }

    global GameSettings(Game_Settings__mdt settings) {
        this.id = settings.Id;
        this.playerAppUrl = settings.Player_App_URL__c;
        this.playerAppUrlMinified = settings.Player_App_URL_Minified__c;
        this.gameApiKey = settings.Game_API_Key__c;
    }
}