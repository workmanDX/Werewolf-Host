/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-16-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-16-2020   steven.workman@logmein.com   Initial Version
**/
public with sharing class GamePlayerTriggerHelper {
    public static void beforeInsert(Game_Player__c[] newPlayers) {
        Game__c game = [SELECT Id FROM Game__c WHERE Game_Code__c = '1234' LIMIT 1];
        for(Game_Player__c gp : newPlayers){
            gp.Game__c = game.Id;
        }
    }
}