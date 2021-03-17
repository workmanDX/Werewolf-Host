/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-22-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-22-2020   steven.workman@logmein.com   Initial Version
**/
public with sharing class GameCharacterService {
    public Character__c[] getCharacters() {
        Character__c[] characterList = new Character__c[0];
        for(Character__c character : [SELECT Id, Name__c, Image_URL__c, Display_Count__c FROM Character__c WHERE isActive__c = true ORDER BY Name ASC]){
            character.Display_Count__c = character.Display_Count__c == null ? 1 : character.Display_Count__c;
            for(integer i = 0; i < character.Display_Count__c; i++){
                characterList.add(character);
            }
        }
        return characterList;
    }
}