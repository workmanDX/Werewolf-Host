/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-23-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-22-2020   steven.workman@logmein.com   Initial Version
**/
global with sharing class CharacterInfo {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String imageUrl { get; set; }
    @AuraEnabled
    global String name { get; set; }

    global CharacterInfo() {
    }

    global CharacterInfo(Character__c character) {
        this.id = character.Id;
        this.imageUrl = character.Image_URL__c;
        this.name = character.Name__c;
    }

    global static CharacterInfo[] fromRecordList(
        Character__c[] records
    ) {
        CharacterInfo[] characters = new CharacterInfo[0];
        for (Character__c record : records) {
            characters.add(new CharacterInfo(record));
        }
        return characters;
    }
}