/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-20-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-04-2020   steven.workman@logmein.com   Initial Version
**/
public class GameActivityService extends GameAbstractDataService{
    public Game_Activity__c[] getActions(String gameId) {
        return [SELECT Id, Card_Name__c, Set_Game_Activity__c, 
        Game_Card__r.Character__r.Action_Description__c, Game_Card__r.Character__r.Description__c
         FROM Game_Activity__c WHERE Game__c =: gameId];
    }

    public GameActivity[] getCurrentActions(Game__c game){
        GameActivity[] activities = new GameActivity[0];
        Game_Activity__c[] gActivities = new Game_Activity__c[0];

        if(game.Activity__c == 'Voting'){
            gActivities =  [SELECT Id, Card_Name__c, Set_Game_Activity__c, Game_Player__c, Game_Player__r.Name__c, Game_Player__r.Name
                FROM Game_Activity__c WHERE Game__c =: game.Id AND Card_Name__c = null AND Game_Player__r.Center_Player__c = false ORDER BY Game_Player__r.Name DESC];
        } else {
            gActivities =  [SELECT Id, Card_Name__c, Set_Game_Activity__c, Game_Player__c, Game_Player__r.Name,
                Game_Card__r.Character__r.Action_Description__c, Game_Card__r.Character__r.Description__c, Game_Player__r.Name__c 
                FROM Game_Activity__c WHERE Game__c =: game.Id AND Card_Name__c =: game.Activity__c AND Game_Player__r.Center_Player__c = false ORDER BY Game_Player__r.Name DESC];
        }

        activities = GameActivity.fromRecordList(gActivities);
        for(GameActivity ga : activities){
            ga = createActivity(ga, game.Activity__c);
        }
        system.debug('activities = ' + activities);
        return activities;
    }

    public GameActivity createActivity(GameActivity ga, String activity){
        switch on activity{
            when 'Doppelganger' {
                // ga = handleDoppelganger(ga);
            }
            when 'Werewolf' {
                ga = handleWerewolf(ga);
            }
            when 'Minion' {
                ga = handleMinion(ga);
            }
            when 'Mason' {
                ga = handleMason(ga);
            }
            when 'Seer' {
                ga = handleSeer(ga);
            }
            when 'Robber' {
                ga = handleRobber(ga);
            }
            when 'Troublemaker' {
                ga = handleTroublemaker(ga);
            }
            when 'Drunk' {
                ga = handleDrunk(ga);
            }
            when 'Insomniac' {
                ga = handleInsomniac(ga);
            }
            when 'Voting' {
                ga = handleVoting(ga);
            }
            // when 'Done' {
            //     ga = handleDone(ga);
            // }
        }

        return ga;
    }

    public GameActivity handleDoppelganger(GameActivity ga){
        ga.showPlayers = true;
        ga.showUnassigned = false;
        ga.showPlayer = false;
        ga.allowFlip = true;

        return ga;
    }

    public GameActivity handleWerewolf(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 0;
        ga.centerPlayerActionCountMax = 1;
        ga = queryPlayers(ga, 'Werewolf', true);

        return ga;
    }

    public GameActivity handleMinion(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 0;
        ga.centerPlayerActionCountMax = 0;
        ga = queryPlayers(ga, 'Werewolf', false);

        return ga;
    }

    public GameActivity handleMason(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 0;
        ga.centerPlayerActionCountMax = 0;
        ga = queryPlayers(ga, 'Mason', false);

        return ga;
    }

    public GameActivity handleSeer(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 1;
        ga.centerPlayerActionCountMax = 2;
        ga = queryAllPlayers(ga, true);

        return ga;
    }

    public GameActivity handleRobber(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 1;
        ga = queryAllPlayers(ga, false);

        return ga;
    }

    public GameActivity handleTroublemaker(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 2;
        ga = queryAllPlayers(ga, false);
        ga.allowFlip = false;

        return ga;
    }

    public GameActivity handleDrunk(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 0;
        ga.centerPlayerActionCountMax = 1;
        ga = queryAllPlayers(ga, true);

        return ga;
    }

    public GameActivity handleInsomniac(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 0;
        ga = queryPlayers(ga, 'Insomniac', false);

        return ga;
    }

    public GameActivity handleVoting(GameActivity ga){
        ga.showPlayer = false;
        ga.actionCount = 0;
        ga.actionCountMax = 1;
        ga = queryAllPlayers(ga, false);

        return ga;
    }

    public GameActivity queryAllPlayers(GameActivity ga, Boolean includeCenterPlayers){
        Game_Player__c[] players  = new Game_Player__c[0];
        Game_Player__c[] centerCards = new Game_Player__c[0];

        if(ga.actionName != 'Drunk'){

            players = [SELECT Id, Name__c, Final_Game_Card__r.Character__r.Name__c, Center_Player__c 
                                        FROM Game_Player__c WHERE Center_Player__c = false ORDER BY Name ASC];

            Map<String, GameActivity.Player> playersForAction = new Map<String, GameActivity.Player>();

            for(Game_Player__c gp : players){
                GameActivity.Player player = new GameActivity.Player();
                player.name = gp.Name__c;
                player.characterName = gp.Final_Game_Card__r.Character__r.Name__c;
                player.showCharacter = false;
                player.allowFlip = true;
                // player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg';
                player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c+ '.png';
                player.centerPlayer = gp.Center_Player__c;
                player.playerId = gp.Id;

                playersForAction.put(gp.Name__c, player);
            }

            ga.players = playersForAction;
        }


        if(includeCenterPlayers){
            Map<String, GameActivity.Player> centerPlayers = new Map<String, GameActivity.Player>();
            ga.actionCountMax = 1;
            centerCards =  [SELECT Id, Name__c, Final_Game_Card__r.Character__r.Name__c, Center_Player__c 
                        FROM Game_Player__c WHERE Center_Player__c = true  ORDER BY Name ASC];

            for(Game_Player__c gp : centerCards){
                GameActivity.Player player = new GameActivity.Player();
                player.name = gp.Name__c;
                player.characterName = gp.Final_Game_Card__r.Character__r.Name__c;
                player.showCharacter = false;
                player.allowFlip = true;
                // player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg';
                player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c+ '.png';
                player.centerPlayer = gp.Center_Player__c;
                player.playerId = gp.Id;
    
                centerPlayers.put(gp.Name__c, player);
                
            }

            ga.centerPlayers = centerPlayers;
        }
        
        return ga;
    }

    public GameActivity queryPlayers(GameActivity ga, String activity, Boolean includeCenterPlayers){
        Game_Player__c[] players = [SELECT Id, Name__c, Original_Game_Card__r.Character__r.Name__c, Final_Game_Card__r.Character__r.Name__c, Center_Player__c
                                    FROM Game_Player__c WHERE Center_Player__c = false  ORDER BY Name ASC];
        Game_Player__c[] centerCards = new Game_Player__c[0];

        Map<String, GameActivity.Player> playersForAction = new Map<String, GameActivity.Player>();
        Integer werewolfCount = 0;

        for(Game_Player__c gp : players){
            if(gp.Original_Game_Card__r.Character__r.Name__c == activity && activity == 'Werewolf'){
                werewolfCount ++;
            }
            GameActivity.Player player = new GameActivity.Player();
            player.name = gp.Name__c;
            player.characterName = gp.Original_Game_Card__r.Character__r.Name__c;
            player.showCharacter = gp.Original_Game_Card__r.Character__r.Name__c == activity ? true : false;
            // player.characterImage = 'resources/images/characters/' + gp.Original_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg';
            player.characterImage = 'resources/images/characters/' + gp.Original_Game_Card__r.Character__r.Name__c+ '.png';
            player.finalCharacterName = gp.Final_Game_Card__r.Character__r.Name__c;
            // player.finalCharacterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg';
            player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c+ '.png';
            player.centerPlayer = gp.Center_Player__c;
            player.playerId = gp.Id;

            playersForAction.put(gp.Name__c, player);
        }

        ga.players = playersForAction;

        // ga.players = JSON.serialize(playersForAction);

        if(includeCenterPlayers && werewolfCount == 1){
            Map<String, GameActivity.Player> centerPlayers = new Map<String, GameActivity.Player>();
            ga.actionCountMax = 1;
            centerCards =  [SELECT Id, Name__c, Final_Game_Card__r.Character__r.Name__c, Center_Player__c 
                        FROM Game_Player__c WHERE Center_Player__c = true  ORDER BY Name ASC];

            for(Game_Player__c gp : centerCards){
                GameActivity.Player player = new GameActivity.Player();
                player.name = gp.Name__c;
                player.characterName = gp.Final_Game_Card__r.Character__r.Name__c;
                player.showCharacter = false;
                player.allowFlip = true;
                // player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c.toLowercase() + '.jpg';
                player.characterImage = 'resources/images/characters/' + gp.Final_Game_Card__r.Character__r.Name__c+ '.png';
                player.centerPlayer = gp.Center_Player__c;
                player.playerId = gp.Id;
    
                centerPlayers.put(gp.Name__c, player);
                
            }

            ga.centerPlayers = centerPlayers;
            // ga.centerPlayers = JSON.serialize(centerPlayers);
        }
        
        return ga;
    }
}