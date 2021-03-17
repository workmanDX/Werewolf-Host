/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-28-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-21-2020   steven.workman@logmein.com   Initial Version
**/
public with sharing class GameHelper {

    private static final GameSettingsService settingsService = new GameSettingsService();
    private static final GameInfoService gameInfoService = new GameInfoService();
    private static final GameActivityService gameActivityService = new GameActivityService();
    private static final String[] STAGES_TO_IGNORE = new String[]{'SelectCharacters', 'DealCards'};

    public static void pushUpdateToPlayerApp(Game__c game, Game__c oldGame){
        // if(STAGES_TO_IGNORE.contains(game.Stage__c)) return;
        if(game.Stage__c != oldGame.Stage__c || game.Activity__c != oldGame.Activity__c || game.Stage__c == 'Registration'){
            pushStageUpdateToPlayerApp(game.Id);
        }
        
    }

    private static Map<String, GamePlayer> createPlayerMap(GamePlayer[] players){
        Map<String,GamePlayer> playerMap = new Map<String,GamePlayer>();
        for(GamePlayer player : players){
            playerMap.put(player.name, player);
        }
        return playerMap;
    }

    @future(callout=true)
    public static void pushStageUpdateToPlayerApp(Id gameId) {

        Game__c game = GameInfoService.getGameInfo();
        GameInfo infoObj = new GameInfo(game);
        String info = JSON.serialize(infoObj);

        GamePlayer[] allPlayers = GameController.getPlayers(null);
        GamePlayer[] playersWithAction = new GamePlayer[0];

        String activitiesJson;

        GameActivity[] activities = new GameActivity[0];
        Map<String, GameActivity> gameActivityMap = new Map<String, GameActivity>();

        if(game.Activity__c != null && game.Activity__c != 'intro'){
            for(GamePlayer player : allPlayers ){
                if(player.actionName == game.Activity__c){
                    playersWithAction.add(player);
                }
            }

            activities = gameActivityService.getCurrentActions(game);
            for(GameActivity ga : activities){
                gameActivityMap.put(ga.playerName, ga);
            }
            system.debug('gameActivityMap = ' + gameActivityMap);
            activitiesJson = JSON.serialize(gameActivityMap);
            system.debug('activitiesJson = ' + activitiesJson);
        }

        GamePlayer[] players = !playersWithAction.isEmpty() ? playersWithAction : allPlayers;        
        Map<String,GamePlayer> playerMapObj = createPlayerMap(players);
        String playerMap = JSON.serialize(playerMapObj);

        system.debug('game Info = ' + info);
        system.debug('playerMap = ' + playerMap);

        Game_Settings__mdt settings = settingsService.get();

        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(settings.Player_App_URL__c + '/api/game-info');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Api-Key', settings.Game_API_Key__c);
        if(!activities.isEmpty()){
            request.setBody('{ "stage": "' + infoObj.stage + '", "info": ' + info + ', "players": ' + playerMap + ', "actionInfo": ' + activitiesJson + '}');
        } else {
            request.setBody('{ "stage": "' + infoObj.stage + '", "info": ' + info + ', "players": ' + playerMap + '}');
        }
        // request.setBody('{ "stage": "' + info.stage + '" }');

        system.debug('request.body = ' + request.getBody());

        Http httpClient = new Http();
        HttpResponse response = httpClient.send(request);
        if (response.getStatusCode() != 200) {
            throw new GameStagePushException(
                'Failed to push quiz phase update: HTTP ' +
                response.getStatusCode() +
                ' ' +
                response.getBody()
            );
        }
    }

    public class GameStagePushException extends Exception {
    }

    public class InvalidStageException extends Exception {
    }
}