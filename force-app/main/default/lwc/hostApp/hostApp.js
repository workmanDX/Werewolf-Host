import { LightningElement, wire, track } from 'lwc';
import getGameSettings from '@salesforce/apex/GameController.getGameSettings';
import checkSettings from '@salesforce/apex/GameController.checkSettings';
import getGameInfo from '@salesforce/apex/GameController.getGameInfo';
import getGameActions from '@salesforce/apex/GameController.getGameActions';
import revealCards from '@salesforce/apex/GameController.revealCards';
import dealCardsApx from '@salesforce/apex/GameController.dealCards';
import resetAll from '@salesforce/apex/GameController.resetAll';
import * as empApi from 'lightning/empApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/errorUtils';

import { updateRecord } from 'lightning/uiRecordApi';
import GAME_STAGE_FIELD from '@salesforce/schema/Game__c.Stage__c';
import GAME_ID_FIELD from '@salesforce/schema/Game__c.Id';

export default class HostApp extends LightningElement {

    @track playerCount = 5;
    @track selectedCharacters = [];
    @track gameInfo;
    @track isNextButtonDisabled = true;
    @track players = [];
    @track playAudio = false;
    @track gameActivity = 'intro';

    error;    
    gameSettings;    
    currentQuestion;
    narrations = {};
    actionMap = {};
    actionDescription = {};
    subscription;

    HOST_APP_VERSION = '1.0.0';

    showLogs(message){
        window.console.log('hostApp: ', message);
    }

    @wire(getGameSettings)
    wiredQuizSettings({ error, data }) {
        if (data) {
            this.gameSettings = data;
        } else if (error) {
            this.error = reduceErrors(error);
            this.gameSettings = undefined;
        }
    }

    connectedCallback() {
        checkSettings().catch((error) => {
            this.error = reduceErrors(error);
            this.isNextButtonDisabled = true;
        });
        getGameInfo()
            .then((gameInfo) => {
                this.gameInfo = gameInfo;
                window.console.log('gameInfo = ', JSON.stringify(this.gameInfo));
                this.isNextButtonDisabled = false;
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.gameInfo = undefined;
            });
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
        this.showLogs('handlePlayerUpdateEvent ' + JSON.stringify(event.data.payload));
    }

    handleNextButtonClick(){
        this.isNextButtonDisabled = true;
        this.handleGameStageUpdate()
        .then((response) => {
            this.error = undefined;
        })
        .catch((error) => {
            this.error = reduceErrors(error);
            this.gameInfo = undefined;
        });
    }

    handleGameStageUpdate(){
        window.console.log('gameStageUpdate: ', this.gameInfo.stage);
        let newStage = 'Registration';
        switch(this.gameInfo.stage){
            case 'Registration':
                this.showLogs('handleGameStageUpdate: Registration');
                newStage = 'SelectCharacters';
                this.updateGame(newStage);
                break;
            case 'SelectCharacters':
                this.showLogs('handleGameStageUpdate: SelectCharacters');
                newStage = 'DealCards';
                this.updateGame(newStage);                
                break;
            case 'Ready':
                this.showLogs('handleGameStageUpdate: Ready');
                this.gameActivity = 'intro';
                this.playAudio = true;
                newStage = 'PlayGame';
                this.updateGame(newStage); 
                this.startGame();
                break;
            case 'PlayGame':
                this.showLogs('handleGameStageUpdate: PlayGame');
                newStage = 'Voting';
                this.playAudio = false;
                this.updateGame(newStage);
                break;
            case 'Voting':
                this.showLogs('handleGameStageUpdate: Voting');
                this.revealCards();
            default:
                window.console.log('do nothing');
        }        
    }

    revealCards(){
        revealCards({gameId : this.gameInfo.id})
        .then((response) => {
            this.showLogs('revealCards');
            this.template.querySelector('c-main-screen').gameStageUpdate('revealCards');
        })
        .catch((error) => {
            this.error = reduceErrors(error);
        });
    }

    updateGame(newStage){
        this.showLogs('in updateGame: ' + newStage);
        const fields = {};
        fields[GAME_STAGE_FIELD.fieldApiName] = newStage;
        fields[GAME_ID_FIELD.fieldApiName] = this.gameInfo.id;
        const recordUpdate = { fields };
        this.showLogs('fields for update = ' + JSON.stringify(fields));
        updateRecord(recordUpdate)
            .then(() => {
                this.showLogs('updateRecord().then(): ' + newStage);
                this.gameInfo.stage = newStage;
                this.gameUpdateAfter(newStage);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        
    }

    gameUpdateAfter(newStage){
        switch(newStage){
            case 'DealCards':
                this.showLogs('DealCards');
                this.dealCards();
                break;
            case 'Ready':
                this.isNextButtonDisabled = false;
                break;
            case 'Voting':
                this.showLogs('gameAfterUpdate - Voting');
                this.isNextButtonDisabled = true;
                // this.subscribeToPlayerChanges();
        }
    }

    dealCards(){
        this.showLogs('inside deal cards');
        dealCardsApx({characterIds : this.selectedCharacters})
            .then((result) => {
                this.players = result;
                this.showLogs('dealCards result = ' + JSON.stringify(this.players));
                this.isNextButtonDisabled = false;
            })
            .then(() => {
                this.updateGame('Ready');
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.gameInfo = undefined;
            });
    }

    startGame(){
        this.showLogs('inside startGame');
        getGameActions({gameId : this.gameInfo.id})
            .then(result =>{
                this.showLogs('startGame: getGameActions = '+  JSON.stringify(result));
                if (result) {
                    let actionMap = {'intro':'Werewolf', 'Done':'Voting'};
                    for(let i = 0; i < result.length; i++){
                        actionMap[result[i].cardName] =  result[i].setGameActivity;
                        this.actionDescription[result[i].cardName] =  result[i].actionDescription;
                    }
                    this.showLogs('actionMap: ' + JSON.stringify(actionMap));
                    this.showLogs('actionDescription: ' + JSON.stringify(this.actionDescription));
                    this.actionMap = actionMap;
                }
            })
            .then(() => {
                // this.playAudioTrack();
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.gameInfo = undefined;
            });
    }

    handleSelectedCharactersUpdate(event){
        let detail = event.detail;
        this.showLogs('handleSelectedCharactersUpdate detail: ' + JSON.stringify(detail));
        this.selectedCharacters = detail.selectedCharacters;
        if(detail.selectedCharacters.length === (this.playerCount + 3)){
            this.isNextButtonDisabled = false;
        } else {
            this.isNextButtonDisabled = true;
        }
    }

    handlePlayerCountUpdate(event){
        let detail = event.detail;
        this.showLogs('handlePlayerCountUpdate detail: ' + JSON.stringify(detail));
        this.playerCount = detail.playerCount;
    }

    handleVotingUpdate(event){
        let detail = event.detail;
        this.showLogs('handleVotingFinished detail: ' + JSON.stringify(detail));
        this.isNextButtonDisabled = !detail.votingFinished;
    }

    subscribeToPlayerChanges(){
        let topic = '/topic/P-'+ this.gameInfo.Id;
        this.showLogs('subscribeToPlayerChanges topic = '+ topic);
        this.handleSubscribe(topic);
    }

    disconnectedCallback() {
        if (this.subscription) {
            empApi.unsubscribe(this.subscription, () => {
                this.subscription = undefined;
            });
        }
    }

    handleResetClick(){
        this.showLogs('handleResetAll');
        resetAll({gameId : this.gameInfo.id})
        .then((result) => {
            this.gameInfo = null;
            this.connectedCallback();
        })
        .catch((error) => {
            this.error = reduceErrors(error);
            this.gameInfo = undefined;
        });
    }

    get isRegistrationStage() {
        window.console.log("gameInfo = ", this.gameInfo);
        return this.gameInfo.stage === 'Registration';
    }

    get gameStageLabel() {
        if (this.gameInfo) {
            if (this.isRegistrationStage) return 'Registration';
            if (this.isSelectCharactersStage) return 'Select Characters';
            if (this.isDealingStage) return 'Dealing Cards';
            if (this.isReadyStage) return this.gameInfo.stage;
            if (this.isVotingStage) return 'Voting';
            // if (this.isQuestionResultsPhase) return 'Answer';
            // if (this.isGameResultsPhase) return 'Game Over';
        }
        return 'Loading...';
    }

    get isRegistrationStage() {
        return this.gameInfo.stage === 'Registration';
    }

    get isSelectCharactersStage() {
        return this.gameInfo.stage === 'SelectCharacters';
    }

    get isDealingStage() {
        return this.gameInfo.stage === 'Dealing Cards';
    }

    get isReadyStage() {
        return this.gameInfo.stage === 'Ready' || this.gameInfo.stage === 'PlayGame'
    }

    get isVotingStage() {
        return this.gameInfo.stage === 'Voting';
    }

    get nextButtonText() {
        if (this.gameInfo) {
            if (this.isRegistrationStage) return 'Select Characters';
            if (this.isSelectCharactersStage) return 'Deal Cards';
            if (this.isReadyStage) return 'Start Game';
            if (this.isVotingStage) return 'Voting Done';
            if (this.isGameResultsPhase) return 'New Game';
            return 'Next';
        }
        return 'Loading...';
    }

    get showMainScreen(){
        return this.isReadyStage || this.isVotingStage;
    }

    get showModal(){
        return this.gameInfo.stage === 'PlayGame';
    }

    /******************Streaming*********************/

    @track payload;

    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;
    // responseInfo;

    subscription = {};

    // Handles subscribe button click
    handleSubscribe(channelName) {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            let responseInfo = JSON.parse(JSON.stringify(response)).data.sobject;
            this.showLogs('subscribe Response: responseInfo = '+ JSON.stringify(responseInfo));
            if(responseInfo.Id.startsWith('a00')){
                this.handleStatusChangeNew(responseInfo.Status__c, this.postWait);
            } else {
                this.handlePlayerChange(responseInfo);
            }                     
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on successful subscribe call
            this.showLogs('Successfully subscribed to : ' + JSON.stringify(response.channel));
            this.subscription = response;
            this.toggleSubscribeButton(true);
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
}