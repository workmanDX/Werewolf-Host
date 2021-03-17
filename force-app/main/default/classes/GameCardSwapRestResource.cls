/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-19-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-16-2020   steven.workman@logmein.com   Initial Version
**/
@RestResource(urlMapping='/game/cardSwap')
global abstract class GameCardSwapRestResource {
    
    @HttpPost
    global static void cardSwap(String player1Id, String player2Id, String actionId) {
        String gameStage = [SELECT Id, Game__r.Stage__c FROM Game_Activity__c WHERE Id =: actionId LIMIT 1].Game__r.Stage__c;
        if(gameStage == 'Voting'){
            system.debug('cardSwap Voting');
            Game_Player__c ga = new Game_Player__c(
                Id = player2Id
                ,Voted_For__c = player1Id
            );
            update ga;
        } else {
            System.debug('player1Id = ' + player1Id);
            System.debug('player2Id = ' + player2Id);
            Set<Id> playerIds = new Set<Id>{player1Id, player2Id};

            Game_Player__c[] players = [SELECT Id, Final_Game_Card__c FROM Game_Player__c 
                    WHERE Id IN :playerIds];
            Id card1Id = players[0].Final_Game_Card__c;
            Id card2Id = players[1].Final_Game_Card__c;

            players[0].Final_Game_Card__c = card2Id;
            players[1].Final_Game_Card__c = card1Id;

            update players;

            Game_Activity__c ga = new Game_Activity__c(
                Id = actionId
                ,Complete__c = true
            );
            update ga;
        }
    }

    global class ErrorMessage {
        ErrorMessage(String message) {
            this.message = message;
        }
        String message;
    }
}