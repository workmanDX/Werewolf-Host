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
global class GamePlayerWrapper implements Comparable {
    public Game_Player__c gPlayer;

    public GamePlayerWrapper(Game_Player__c gp) {
        gPlayer = gp;
    }

    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        GamePlayerWrapper compareToGamePlayer = (GamePlayerWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (gPlayer.Votes_Against__c < compareToGamePlayer.gPlayer.Votes_Against__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (gPlayer.Votes_Against__c > compareToGamePlayer.gPlayer.Votes_Against__c) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((gPlayer.Votes_Against__c != null) && (compareToGamePlayer.gPlayer.Votes_Against__c != null)){
            // nulls-last implementation
            returnValue = -1;
        } else if ((gPlayer.Votes_Against__c == null) && (compareToGamePlayer.gPlayer.Votes_Against__c == null)){
            // nulls-last implementation
            returnValue = 1;
        }        
        return returnValue;       
    }
}