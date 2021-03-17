import { LightningElement, api, track } from 'lwc';
import getPlayers from '@salesforce/apex/GameController.getPlayers';
import { reduceErrors } from 'c/errorUtils';
import * as empApi from 'lightning/empApi';
import PLAYER_OBJECT from '@salesforce/schema/Game_Player__c';

export default class PlayerList extends LightningElement {
    error;
    @track playerNames = [];
    @api gameInfo;

    subscription;

    showLogs(message){
        window.console.log('playerList: ', message);
    }

    showLogsJson(message, obj){
        window.console.log('playerApp: ', message, ': ', JSON.stringify(obj));
    }

    connectedCallback() {
        getPlayers()
            .then((players) => {
                this.playerNames = players.map((player) => player.name);
                this.error = undefined;
                this.updatePlayerCount();
                this.initEmpApi();
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.playerNames = undefined;
            });
    }

    initEmpApi() {
        const ns = PlayerList.getNamespacePrefix(PLAYER_OBJECT.objectApiName);
        empApi.onError((error) => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe(
                `/data/${ns}Game_Player__ChangeEvent`,
                -1,
                (cdcEvent) => {
                    if (
                        cdcEvent.data.payload.ChangeEventHeader.changeType ===
                        'CREATE'
                    ) {
                        this.handlePlayerCreationEvent(cdcEvent);
                    }
                }
            )
            .then((response) => {
                this.subscription = response;
            });
    }

    static getNamespacePrefix(objectApiName) {
        if (objectApiName.match(/__/g).length === 2) {
            return objectApiName.split('__')[0] + '__';
        }
        return '';
    }

    handlePlayerCreationEvent(cdcEvent) {
        this.showLogsJson('handlePlayerCreationEvent: ', cdcEvent.data.payload);
        this.showLogsJson('handlePlayerCreationEvent Center_Player__c: ', cdcEvent.data.payload.Center_Player__c);
        const name = cdcEvent.data.payload.Name__c;
        const gameId = cdcEvent.data.payload.Game__c;
        const centerPlayer = cdcEvent.data.payload.Center_Player__c
        if (gameId == this.gameInfo.id && !this.playerNames.includes(name) && !centerPlayer) {
            this.playerNames.push(name);
            this.updatePlayerCount();
        }
    }

    updatePlayerCount(){
        let eventDetails = {playerCount:this.playerNames.length};

        const event = new CustomEvent('updateplayercount', {
            // detail contains only primitives
            detail: eventDetails
        });
        this.showLogs('updatePlayerCount Event, Details: ' + JSON.stringify(eventDetails));
        // Fire the event from c-tile
        this.dispatchEvent(event);
    }

    disconnectedCallback() {
        if (this.subscription) {
            empApi.unsubscribe(this.subscription, () => {
                this.subscription = undefined;
            });
        }
    }

    get playerCount() {
        return this.playerNames ? `(${this.playerNames.length})` : '';
    }
}