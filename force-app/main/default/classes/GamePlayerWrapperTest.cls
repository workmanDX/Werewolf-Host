/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-03-2020   steven.workman@logmein.com   Initial Version
**/
@isTest
private class GamePlayerWrapperTest {
    static testmethod void test1() {
        // Add the opportunity wrapper objects to a list.
        GamePlayerWrapper[] gPlayerList = new List<GamePlayerWrapper>();
        gPlayerList.add( new GamePlayerWrapper(new Game_Player__c(
                Name__c='Steven',
                Votes_Against__c=0
            )));
            gPlayerList.add( new GamePlayerWrapper(new Game_Player__c(
                Name__c='Natalie',
                Votes_Against__c=3
            )));
            gPlayerList.add( new GamePlayerWrapper(new Game_Player__c(
                Name__c='Kanessa',
                Votes_Against__c=1
            )));
        
        // Sort the wrapper objects using the implementation of the 
        // compareTo method.
        gPlayerList.sort();

        System.debug('gPlayerList: ' + gPlayerList);
        
        // Verify the sort order
        // System.assertEquals('Natalie', gPlayerList[0].gPlayer.Name__c);
        // System.assertEquals(3, gPlayerList[0].gPlayer.Votes_Against__c);
        // System.assertEquals('Kanessa', gPlayerList[1].gPlayer.Name__c);
        // System.assertEquals(1, gPlayerList[1].gPlayer.Votes_Against__c);
        // System.assertEquals('Steven', gPlayerList[2].gPlayer.Name__c);
        // System.assertEquals(1, gPlayerList[2].gPlayer.Votes_Against__c);
        
        // Write the sorted list contents to the debug log.
        
    }

    static testmethod void test2() {
        // Add the opportunity wrapper objects to a list.
        Game_Player__c[] gPlayerList = new Game_Player__c[0];
        gPlayerList.add(new Game_Player__c(
            Name__c='Steven',
            Votes_Against__c=0
        ));
        gPlayerList.add( new Game_Player__c(
            Name__c='Natalie',
            Votes_Against__c=3
        ));
        gPlayerList.add( new Game_Player__c(
            Name__c='Kanessa',
            Votes_Against__c=1
        ));

        gPlayerList.add( new Game_Player__c(
            Name__c='Mika'
        ));

        insert gPlayerList;

        Game_Player__c[] sortedPlayers = GamePlayerService.sortByVotes(gPlayerList);

        System.debug('sortedPlayers: ' + sortedPlayers);
        
        // Verify the sort order
        // System.assertEquals('Natalie', gPlayerList[0].gPlayer.Name__c);
        // System.assertEquals(3, gPlayerList[0].gPlayer.Votes_Against__c);
        // System.assertEquals('Kanessa', gPlayerList[1].gPlayer.Name__c);
        // System.assertEquals(1, gPlayerList[1].gPlayer.Votes_Against__c);
        // System.assertEquals('Steven', gPlayerList[2].gPlayer.Name__c);
        // System.assertEquals(1, gPlayerList[2].gPlayer.Votes_Against__c);
        
        // Write the sorted list contents to the debug log.
        
    }
}