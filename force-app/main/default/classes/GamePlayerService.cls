/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-19-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
public class GamePlayerService extends GameAbstractDataService {

    public final String playerFields = 'SELECT Id, Name__c, Final_Card_Image__c, Center_Player__c,' +
                                        'Killed__c, Reveal__c, Votes_Against__c, Voted_For__c, ' +
                                        'Original_Game_Card__r.Character__r.Action_Description__c, Original_Game_Card__r.Character__r.Description__c, '+
                                        'Original_Game_Card__r.Character__r.Image_URL__c, Original_Game_Card__r.Character__r.Name__c, '+
                                        'Final_Game_Card__r.Character__r.Name__c';

    public Game_Player__c getFromId(Id playerId) {
        return (Game_Player__c) getSingleRecord(
            'Game_Player__c',
            [
                SELECT Id, Name__c
                FROM Game_Player__c
                WHERE Id = :playerId
            ]
        );
    }

    public Game_Player__c getFromName(String name) {
        return (Game_Player__c) getSingleRecord(
            'Game_Player__c',
            [SELECT Id FROM Game_Player__c WHERE Name = :name]
        );
    }

    public Game_Player__c[] getPlayers(Integer maxFetchCount, Boolean centerPlayers) {
        String query = playerFields + ' FROM Game_Player__c WHERE Center_Player__c =: centerPlayers ORDER BY Name ASC';
        if (maxFetchCount != null) {
            query += ' LIMIT ' + maxFetchCount;
        }
        return Database.query(query);
    }

    // public Map<Id, Game_Player__c> getPlayers() {
    public Map<Id, Game_Player__c> getPlayersMap() {
        return new Map<Id, Game_Player__c>(
            [SELECT Id, Name__c FROM Game_Player__c]
        );
    }

    public void createCenterPlayers(Id gameId){
        String[] nickNames = new String[]{'Dwight', 'Jim', 'Pam', 'Angela', 'Kevin', 'Oscar', 'Stanley', 'Creed', 'Andy', 'Toby', 'Meredith', 'Erin', 'Ron', 'Leslie', 'Ann', 'Andy', 'Ben', 'Tom', 'Jerry', 'April', 'Donna','Chris'};
        Game_Player__c[] players = new Game_Player__c[0];
        String tempNickName;

        for(integer i = 0; i < 3; i ++){
            Integer nameIndex = (Math.random() * (nickNames.size()-1)).intValue();
            tempNickName = nickNames[nameIndex];
            nickNames.remove(nameIndex);

            Game_Player__c player = new Game_Player__c(
                Game__c = gameId
                , Name__c = tempNickName
                , Center_Player__c = true
            );
            players.add(player);
        }

        insert players;
    }

    public Game_Player__c[] dealCards(String[] characterIds){
        Game__c game = [SELECT Id FROM Game__c WHERE Stage__c = 'DealCards' LIMIT 1];
        Game_Card__c[] gameCards = createGameCards(characterIds, game.Id);


        Set<Id> playerIds = new Set<Id>();
        Game_Player__c[] players = [SELECT Id, Name__c, Original_Game_Card__c, Final_Game_Card__c, Center_Player__c FROM Game_Player__c WHERE Game__c =: game.Id ORDER BY Name__c ASC];
        for(Game_Player__c player : players){
            if(player.Name__c.contains('Test')){
                integer i = 0;
                for(Game_Card__c gc :gameCards){                    
                    if(gc.Character__c == 'a004x000001SaFg'){
                        player.Original_Game_Card__c = gc.Id;
                        player.Final_Game_Card__c = gc.Id;
                        break;
                    } else {
                        i++;
                    }
                }
                gameCards.remove(i);
            } else {
                Integer index = (Math.random() * (gameCards.size()-1)).intValue();
                Game_Card__c gc = gameCards[index];
                player.Original_Game_Card__c = gc.Id;
                player.Final_Game_Card__c = gc.Id;

                gameCards.remove(index);
                playerIds.add(player.Id);
            }
        }

        system.debug('players = ' + players);
        update players;

        createActivitiesNew(game, players);

        String query = playerFields + ' FROM Game_Player__c WHERE Id IN: playerIds';
        system.debug('query = '+ query);

        return Database.query(query);

    }

    public Game_Player__c[] dealCards_Original(String[] characterIds){
        Game__c game = [SELECT Id FROM Game__c WHERE Stage__c = 'DealCards' LIMIT 1];
        Game_Card__c[] gameCards = createGameCards(characterIds, game.Id);
        Set<Id> playerIds = new Set<Id>();
        Game_Player__c[] players = [SELECT Id, Name__c, Original_Game_Card__c, Final_Game_Card__c, Center_Player__c FROM Game_Player__c WHERE Game__c =: game.Id ORDER BY Name__c ASC];
        for(Game_Player__c player : players){
            Integer index = (Math.random() * (gameCards.size()-1)).intValue();
            Game_Card__c gc = gameCards[index];
            player.Original_Game_Card__c = gc.Id;
            player.Final_Game_Card__c = gc.Id;

            gameCards.remove(index);
            playerIds.add(player.Id);
        }

        system.debug('players = ' + players);
        update players;

        createActivitiesNew(game, players);

        String query = playerFields + ' FROM Game_Player__c WHERE Id IN: playerIds';
        system.debug('query = '+ query);

        return Database.query(query);

    }

    public Game_Card__c[] createGameCards(String[] characterIds, Id gameId){
        Game_Card__c[] gameCards = new Game_Card__c[0];
        // Map<Id, Character__c> characterMap = new Map<Id, Character__c>([SELECT Id, Name__c, Image_URL__c FROM Character__c WHERE Id IN: characterIds]);
        for(string characterId : characterIds){
            Game_Card__c gameCard = new Game_Card__c(
                Game__c = gameId
                ,Character__c = characterId
            );
            gameCards.add(gameCard);
        }
        insert gameCards;
        return gameCards;
    }

    public void createActivitiesNew(Game__c game, Game_Player__c[] players){
        system.debug('createActivities cards');
        Map<String, cardOrder> cardMap = setGameCardMap(game.Id);
        Game_Activity__c[] gaList = new Game_Activity__c[0];
        for(Game_Player__c player : players){
            system.debug('player = ' + player);
            if(cardMap.containsKey(player.Original_Game_Card__c)){
                Game_Activity__c ga = new Game_Activity__c(
                    Game__c = game.Id
                    , Game_Card__c = player.Original_Game_Card__c
                    , Game_Player__c = player.Id
                    , Order__c = cardMap.get(player.Original_Game_Card__c).order
                    , Set_Game_Activity__c = cardMap.get(player.Original_Game_Card__c).nextStatus
                );
                gaList.add(ga);
            }
            if(player.Center_Player__c) continue;
            
            Game_Activity__c voteActivity = new Game_Activity__c(
                Game__c = game.Id
                , Game_Player__c = player.Id
                , Order__c = 99
            );
            gaList.add(voteActivity);
        }

        insert gaList;
    }

    public static Map<String, cardOrder> setGameCardMap(Id gameId){
        // need to create a map of gamecards with the cardname as the key and a set of card names and then take the nextStatus from the set
        Map<String, cardOrder> orderMap = new Map<String, cardOrder>();
        Map<String, cardOrder> orderMapNames = new Map<String, cardOrder>();
        Map<String, Game_Card__c[]> gcMap = new Map<String, Game_Card__c[]>();

        Game_Card__c[] cardList = [SELECT Id, Name, Character__r.Name__c, Character__r.Order__c FROM Game_Card__c WHERE Game__c =: gameId AND Character__r.Order__c != null ORDER BY Character__r.Order__c ASC];
        for(Game_Card__c gc : cardList){
            if(gcMap.containsKey(gc.Character__r.Name__c)){
                gcMap.get(gc.Character__r.Name__c).add(gc);
            } else {
                gcMap.put(gc.Character__r.Name__c, new Game_Card__c[]{gc});
            }

        }
        String[] statusList = new String[gcMap.keySet()];
        system.debug('statusList = '+ statusList);

        integer i = 0;
        for(String cName : gcMap.keySet()){
            for(Game_Card__c gc : gcMap.get(cName)){
                cardOrder co = new cardOrder();
                co.order = i;
                system.debug('i = ' + i);
                system.debug('nextStatus = ' + gcMap.get(statusList[i])[0].Character__r.Name__c);
                co.nextStatus = (i == statusList.size() - 1) ? 'Done' : gcMap.get(statusList[i + 1])[0].Character__r.Name__c;
                ordermap.put(gc.Id, co);
                system.debug('co = ' + co);
            }
            i++;
        }
        system.debug('orderMap = ' + orderMap);
        return orderMap;
    }

    public void revealCards(String gameId){
        Game_Player__c[] playerList = [SELECT Id, Reveal__c, Killed__c, Votes_Against__c, Voted_For__c, Final_Card_Name__c FROM Game_Player__c WHERE Game__c =: gameId];
        // if(playerList[0].Game__r.Number_of_Players__c == (playerList.size()-3)){
            AggregateResult[] aggPlayers = [SELECT COUNT(Id) vCount, Voted_For__c FROM Game_Player__c WHERE Game__c =: gameId GROUP BY Voted_For__c ORDER BY COUNT(ID) DESC NULLS LAST];
            Map<String, Integer> aggMap = new Map<String, Integer>();
            for(AggregateResult ap : aggPlayers){
                system.debug('ap: ' + ap);
                aggMap.put(string.valueOf(ap.get('Voted_For__c')), integer.valueOf(ap.get('vCount')));
            }
            for(Game_Player__c player : playerList){
                player.Reveal__c = true;
                player.Votes_Against__c = aggMap.containsKey(player.Id) ? aggMap.get(player.Id) : 0;
            }
            // update playerList;
            sortByVotes(playerList);            
        // }
    }

    public static void sortByVotes(Game_Player__c[] players){
        GamePlayerWrapper[] gPlayerList = new List<GamePlayerWrapper>();
        Map<Id, Game_Player__c> gpMap = new Map<Id, Game_Player__c>(players);
        for(Game_Player__c gp : players){
            gPlayerList.add( new GamePlayerWrapper(gp));
        }
        gPlayerList.sort();
        
        Game_Player__c[] sortedPlayers = new Game_Player__c[0];
        for(GamePlayerWrapper gPlayer : gPlayerList){
            sortedPlayers.add(gpMap.get(gPlayer.gPlayer.Id));
        }
        killPlayer(sortedPlayers);
    }

    public static void killPlayer(Game_Player__c[] players){
        Set<Id> playerIds = new Set<Id>();
        Double maxVotes = players[0].Votes_Against__c;
        Id killHuntersVote = null;
        for(Game_Player__c player : players){
            if(player.Votes_Against__c >= maxVotes){
                maxVotes = player.Votes_Against__c;
                player.Killed__c = true;
                playerIds.add(player.Id);

                if(player.Final_Card_Name__c == 'Hunter'){
                    killHuntersVote = player.Voted_For__c;
                }
            } else {
                break;
            }
        }
        Map<Id, Game_Player__c> gpMap = new Map<Id, Game_Player__c>(players);
        if(killHuntersVote != null){            
            gpMap.get(killHuntersVote).Killed__c = true;
        }
        system.debug('playersToUpdate = ' + gpMap.values());
            
        update gpMap.values();
    }

    public void deleteAnswersAndPlayers() {
        // delete [SELECT Id FROM Quiz_Answer__c];
        delete [SELECT Id FROM Game_Player__c];
    }

    // public void assignRanking() {
    //     Game_Player__c[] players = getPlayers(null);
    //     Decimal lastScore = 9223372036854775807L; // Long max value
    //     Integer rank = 0;
    //     for (Game_Player__c player : players) {
    //         // if previous score is larger than current score, increment rank
    //         if (lastScore > player.Score__c) {
    //             rank++;
    //         }
    //         player.Ranking__c = rank;
    //         lastScore = player.Score__c;
    //     }
    //     update players;
    // }

    public class cardOrder{
        @AuraEnabled public integer order;
        @AuraEnabled public String nextStatus;
    }
}