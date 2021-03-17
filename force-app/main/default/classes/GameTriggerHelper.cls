/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-06-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-21-2020   steven.workman@logmein.com   Initial Version
**/
public with sharing class GameTriggerHelper {
    // private static final String STAGE_REGISTRATION = QuizSessionService.Phase.Registration.name();
    private static final String STAGE_SELECTION = 'SelectCharacters';
    
    public static void afterUpdate(
        Game__c[] updatedGames,
        Map<Id, Game__c> oldGames
    ) {
        for (Game__c updatedGame : updatedGames) {
            Game__c oldGame = oldGames.get(updatedGame.Id);
            //has stage changed?
            if (updatedGame.Stage__c != oldGame.Stage__c) {
                if (updatedGame.Stage__c == STAGE_SELECTION) {
                    //create player push topic
                    PushTopic playerPT = new PushTopic();
                    playerPT.Name = 'P-'+updatedGame.Id;
                    playerPT.Query = 'SELECT Id, Name__c, Original_Card_Name__c, Reveal__c, Killed__c, Final_Card_Image__c, Voted_For__c, Votes_Against__c FROM Game_Player__c WHERE Game__c = \'' + updatedGame.Id + '\'';
                    playerPT.ApiVersion = 48.0;
                    playerPT.NotifyForOperationCreate = false;
                    playerPT.NotifyForOperationUpdate = true;
                    playerPT.NotifyForOperationUndelete = false;
                    playerPT.NotifyForOperationDelete = false;
                    playerPT.NotifyForFields = 'Referenced';

                    insert playerPT;
                }
            }

            // Push stage change to player app
            GameHelper.pushUpdateToPlayerApp(updatedGame, oldGame);
        }
    }
}