/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-23-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
public class GameSettingsService extends GameAbstractDataService {
    public Game_Settings__mdt get() {
        Game_Settings__mdt settings;
        if (Test.isRunningTest()) {
            settings = new Game_Settings__mdt(
                Player_App_URL__c = 'https://mock-full.url',
                Player_App_URL_Minified__c = 'https://mock-mini.url',
                Game_API_Key__c = 'mock-key'
            );
        } else {
            settings = (Game_Settings__mdt) getSingleRecord(
                'Game_Settings__mdt',
                [
                    SELECT
                        Id,
                        Player_App_URL__c,
                        Player_App_URL_Minified__c,
                        Game_API_Key__c
                    FROM Game_Settings__mdt
                ]
            );
        }
        // Normalize player app URL
        settings.Player_App_URL__c = settings.Player_App_URL__c.removeEnd('/');
        return settings;
    }

    public void checkSettings() {
        // Check for a unique settings record
        Game_Settings__mdt settings = this.get();
        // Check that player app can be reached (remote site is configured and URL is valid)
        HttpRequest req = new HttpRequest();
        req.setEndpoint(settings.Player_App_URL__c);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 300) {
            throw new PlayerAppUrlException(
                'Failed to reach player app (HTTP ' +
                res.getStatusCode() +
                '). Check if URL is valid: ' +
                settings.Player_App_URL__c
            );
        }
    }

    public class PlayerAppUrlException extends Exception {
    }
}