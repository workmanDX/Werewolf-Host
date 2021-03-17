/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-23-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
public with sharing class GameController {

    private static final GameInfoService gameInfoService = new GameInfoService();
    private static final GameSettingsService settingsService = new GameSettingsService();
    private static final GamePlayerService playerService = new GamePlayerService();
    private static final GameCharacterService characterService = new GameCharacterService();
    private static final GameActivityService activityService = new GameActivityService();
    private static final GameHelper gameHelper = new GameHelper();


    @AuraEnabled(cacheable=true)
    public static GameSettings getGameSettings() {
        Game_Settings__mdt settings = settingsService.get();
        return new GameSettings(settings);
    }

    @AuraEnabled
    public static void checkSettings() {
        try {
            settingsService.checkSettings();
        } catch (Exception e) {
            throw new AuraHandledException(
                'Failed to validate Game app settings: ' + e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static GameInfo getGameInfo() {
        //add logic here to create a game and the three center players
        Game__c game = gameInfoService.getGameInfo();
        //make sure three cetner players exist
        verifyCenterPlayers(game.Id);
        return new GameInfo(game);
    }

    public static void verifyCenterPlayers(Id gameId){
        //check for center players
        Game_Player__c[] players = [SELECT Id FROM Game_Player__c WHERE Game__c =: gameId AND Center_Player__c = true];
        if(players.size() == 3) return;
        playerService.createCenterPlayers(gameId);
    }

    @AuraEnabled
    public static GamePlayer[] getPlayers(Integer maxFetchCount) {
        Game_Player__c[] players = playerService.getPlayers(maxFetchCount, false);
        return GamePlayer.fromRecordList(players);
    }

    @AuraEnabled
    public static CharacterInfo[] getCharacterList(){
        try {
            Character__c[] characterList = characterService.getCharacters();
            return CharacterInfo.fromRecordList(characterList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static GamePlayer[] dealCards(String[] characterIds){
        try {
            Game_Player__c[] players = playerService.dealCards(characterIds);
            return GamePlayer.fromRecordList(players);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static gameDetails getGameDetails(String gameId){
        gameDetails gameInfo = new gameDetails();
        Game_Player__c[] players = playerService.getPlayers(null, false);
        gameInfo.players = GamePlayer.fromRecordList(players);

        Game_Player__c[] centerCards = playerService.getPlayers(null, true);
        gameInfo.centerCards = GamePlayer.fromRecordList(centerCards);

        return gameInfo;
    }

    @AuraEnabled
    public static gameAction[] getGameActions(String gameId){
        try {
            Game_Activity__c[] actions = activityService.getActions(gameId);
            return GameAction.fromRecordList(actions);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void revealCards(String gameId){
        playerService.revealCards(gameId);
    }

    public class gameDetails{
        @AuraEnabled public GamePlayer[] players;
        @AuraEnabled public GamePlayer[] centerCards;
    }

    @AuraEnabled
    public static void resetAll(String gameId){
        Game_Card__c[] gCards = [SELECT Id FROM Game_Card__c WHERE Game__c =: gameId];
        delete gCards;

        Game_Activity__c[] actions = [SELECT Id FROM Game_Activity__c WHERE Game__c =: gameId];
        delete actions;

        PushTopic[] pt = [SELECT Id FROM PushTopic];
        delete pt;

        Game__c g = [SELECT Id, Stage__c, Activity__c FROM Game__c WHERE Id =: gameId LIMIT 1];
        g.Stage__c = 'Registration';
        g.Activity__c = null;
        update g;

        // Game_Player__c[] gp = [SELECT Id FROM Game_Player__c WHERE (NOT Name__c LIKE 'steven%') AND Center_Player__c = false];
        Game_Player__c[] gp = [SELECT Id FROM Game_Player__c WHERE Game__c =: gameId];
        delete gp;
    }

    @AuraEnabled
    public static Game__c gameSetup(String[] selectedCards){
        // Integer cardCount = selectedCards.size();
        // system.debug('selectedCards = ' + selectedCards);
        // Set<String> selectedSet = new Set<String>();
        // selectedSet.addAll(selectedCards);
        // Map<Id, Character__mdt> characters = getCardsById(selectedSet);

        // Game__c game = new Game__c(
        //     Number_of_Players__c = cardCount - 3
        //     ,Status__c = 'Pending'
        //     ,Game_Code__c = generateRandomString(4)
        //     ,Card_Back_Image__c = randomCardBack()
        // );

        // insert game;

        // Game_Card__c[] gameCards = new Game_Card__c[0];
        // for(string cardId : selectedCards){
        //     Character__mdt character = characters.get(cardId);
        //     Game_Card__c gameCard = new Game_Card__c(
        //         Game__c = game.id
        //         ,Card_Image_URL__c = character.URL__c
        //         ,Card_Name__c = character.MasterLabel
        //     );
        //     gameCards.add(gameCard);
        // }
        // insert gameCards;
        
        // system.debug('cards after insert = ' + gameCards);
        // Game_Card__c[] newCards = new Game_Card__c[0];
        // newCards.addAll(gameCards);
        // system.debug('cards after insert = ' + newCards);

        // Player__c[] players = createPlayers(gameCards, game, cardCount);
        // insert players;

        // // Game_Activity__c[] gActivities = createActivities(game, players, newCards);
        // // insert gActivities;
        // // system.debug('activities = ' + gActivities);

        // createPushTopic(game.Id);
        
        // return game;
        return null;
        
    }

    // @AuraEnabled
    // public static GameInfo triggerNextStage(Id gameId, String stage) {
    //     if (gameId == null) {
    //         throw new AuraHandledException('Missing game Id.');
    //     }
    //     Game__c game = gameHelper.triggerNextStage(gameId, stage);
    //     return new GameInfo(game);
    // }
}