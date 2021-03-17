import { LightningElement, track, api, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor'
import { updateRecord } from 'lightning/uiRecordApi';
import PLAYER_ID_FIELD      from '@salesforce/schema/Game_Player__c.Id';
import PLAYER_NICKNAME_FIELD from '@salesforce/schema/Game_Player__c.Name__c';
import * as empApi from 'lightning/empApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CardDisplay extends LightningElement {
    @api cardBack;
    @api card;

    @track voted = false;
    @track showReset = false;

    formFactor = FORM_FACTOR;
    subscription;

    showLogs(message){
        window.console.log('cardDisplay: ', message);
    }

    connectedCallback(){
        this.isSelected = false;
        this.voted = false;
        if(this.card){
            this.initEmpApi();
        }
    }

    initEmpApi() {
        empApi.onError((error) => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe(
                `/data/Game_Player__ChangeEvent`,
                -1,
                (cdcEvent) => {
                    if (
                        cdcEvent.data.payload.ChangeEventHeader.changeType ===
                        'UPDATE'
                    ) {
                        this.handlePlayerUpdateEvent(cdcEvent);
                    }
                }
            )
            .then((response) => {
                this.subscription = response;
            });
    }

    handlePlayerUpdateEvent(event){
        let payload = event.data.payload;
        let changedId = payload.ChangeEventHeader.recordIds[0];
        if(changedId === this.card.id){
            if(payload.ChangeEventHeader.changedFields.includes('Voted_For__c')){
                let cField = payload.Voted_For__c;
                this.showLogs('cField = ' + cField);
                if(cField != null){
                    this.voted = true;
                    this.handleVotedAction();
                } else {
                    this.voted = false;
                    this.handleVotedAction();
                }
            }
        }
    }

    handleVotedAction(){
        this.showLogs('handleVotedAction');
        let eventDetails = {id:this.card.id, voted:this.voted};

        const event = new CustomEvent('playervote', {
            // detail contains only primitives
            detail: eventDetails
        });
        this.showLogs('handleVotedAction Event, Details: ' + JSON.stringify(eventDetails));
        // Fire the event from c-cardDisplay
        this.dispatchEvent(event);
    }

    disconnectedCallback() {
        if (this.subscription) {
            empApi.unsubscribe(this.subscription, () => {
                this.subscription = undefined;
            });
        }
    }

    get cardImage(){
        if(this.card.reveal){
            return this.card.finalImage;
        } else {
            return this.cardBack;
        }

    }

    get cardClass(){
        // this.showLogs('cardClass: this.Card: ' + JSON.stringify(this.card));
        let cssClass = 'cardimage';

        if(this.voted || this.card.reveal){
            cssClass += ' true';
        } else {
            cssClass += ' false';
        }
        
        if(this.card.killed){
            cssClass += ' killed';
        }
        return cssClass;
    }

    get showVotes(){
        if(this.card.reveal && this.card.voted){
            return true;
        } else {
            return false;
        }
    }

    get imageWidth(){
        let width = 120
        if(this.formFactor === 'Small'){
            width = 40;
        } 
        else if(this.formFactor === 'Medium'){
            width = 80;
        }
        // this.showLogs('width = ', width);
        return width;
    }

    get imageHeight(){
        let height = 150;
        if(this.formFactor === 'Small'){
            height = 50;
        } 
        else if(this.formFactor === 'Medium'){
            height = 100;
        }
        // this.showLogs('height = ', height);
        return height;       
    }

    /***************Potentially add this back in to reset players during registration **********************/

    handleResetPlayer(){
        const fields = {};
        fields[PLAYER_ID_FIELD.fieldApiName] = this.card.id;
        fields[PLAYER_NAME_CHANGED_FIELD.fieldApiName] = false;
        fields[PLAYER_NICKNAME_FIELD.fieldApiName] = 'Player';

        const recordUpdate = { fields };
        updateRecord(recordUpdate).then(playerUpdate => {
            this.showReset = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Player Reset',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Unable to reset player',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleResetCancel(){
        this.showReset = false;
    }
}