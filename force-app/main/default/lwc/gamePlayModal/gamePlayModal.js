import { LightningElement, track, api} from 'lwc';

import characterImages from '@salesforce/resourceUrl/characterImages';
import NARRATION_FILES from '@salesforce/resourceUrl/cowboyNarration';

import { updateRecord } from 'lightning/uiRecordApi';
import GAME_STAGE_FIELD from '@salesforce/schema/Game__c.Stage__c';
import GAME_ACTIVITY_FIELD from '@salesforce/schema/Game__c.Activity__c';
import GAME_ID_FIELD from '@salesforce/schema/Game__c.Id';

export default class GamePlayModal extends LightningElement {
    @api actionMap = {};
    @api actionDescription = {};
    @api gameId;

    @track isModalOpen = false;
    @track showProgressBar = false;
    @track gameActivity = 'pending';
    @track description;


    narrations = {};
    extendTime = 1.5;
    audioPlay = true;

    showLogs(message){
        window.console.log('GamePlayModal: ', message);
    }

    connectedCallback(){
        this.prepAudio();
        this.timeDelay();
    }

    closeModal(){
        this.isModalOpen = false;
    }

    prepAudio(){
        this.narrations['intro'] = NARRATION_FILES + '/intro.mp3';
        this.narrations['Werewolf'] = NARRATION_FILES + '/werewolves.mp3';
        this.narrations['Drunk'] = NARRATION_FILES + '/drunk.mp3';
        this.narrations['Insomniac'] = NARRATION_FILES + '/insomniac.mp3';
        this.narrations['Mason'] = NARRATION_FILES + '/masons.mp3';
        this.narrations['Minion'] = NARRATION_FILES + '/minion.mp3';
        this.narrations['Robber'] = NARRATION_FILES + '/robber.mp3';
        this.narrations['Seer'] = NARRATION_FILES + '/seer.mp3';
        this.narrations['Troublemaker'] = NARRATION_FILES + '/troublemaker.mp3';
        this.narrations['Done'] = NARRATION_FILES + '/wrapup.mp3';
        this.showLogs('narrations = ' + JSON.stringify(this.narrations));
    }

    handleCompleteAction(){
        window.console.log('in handleCompleteAction');
        this.showProgressBar = false;
        this.timeDelay();
    } 

    timeDelay(){
        this.showLogs('start wait');
        this.wait(100);
        this.showLogs('end wait');
        this.completeAction();
    }

    wait(ms){
        this.showLogs('in wait');
        var start = new Date().getTime();
        var end = start;
        while(end < start + ms) {
          end = new Date().getTime();
       }
     }    

    completeAction(){
        this.showLogs('in completeAction');
        this.showLogs('current activity: ' + this.gameActivity);
        this.isModalOpen = true;
            let newActivity = this.gameActivity === 'pending' ? 'intro' : this.actionMap[this.gameActivity];
            this.description = this.actionDescription[newActivity];

            this.showLogs('new Activity: ' + newActivity);
            this.showLogs('description: ' + this.description);
            const fields = {};
            fields[GAME_ID_FIELD.fieldApiName] = this.gameId;
            fields[GAME_ACTIVITY_FIELD.fieldApiName] = newActivity;
            const recordInput = { fields };
            this.showLogs('fields for update = ' + JSON.stringify(fields));
            updateRecord(recordInput)
                .then(() => {
                    this.gameActivity = newActivity;                    
                    this.playAudioTrack();
                    if(this.gameActivity == 'Voting'){
                        this.doneEvent();
                    }
                });
    }

    doneEvent(){
        this.showLogs('doneEvent');
        this.dispatchEvent(new CustomEvent('actionsdone'));
    }

    playAudioTrack(){
        this.showLogs('in playAudioTrack, ' + this.gameActivity);
        let audio = this.template.querySelector(".my-audio");
        let nextTrack = this.narrations[this.gameActivity];
        if(nextTrack != undefined && audio != undefined && audio != null){
            audio.src = nextTrack;
            this.showLogs('audio.src = ' + audio.src);
            audio.load();
        }
    }

    handleAudioLoaded (){
        this.showLogs('in handleAudioLoaded, ' + this.gameActivity);
        let audio = this.template.querySelector(".my-audio");
        this.showLogs('duration = ' + audio.duration);
        this.showLogs('currentTime = ' + audio.currentTime);
        this.newDuration = audio.duration + this.extendTime;
        this.template.querySelector('c-progress-bar').resetBar(this.newDuration);
        this.showProgressBar = true;
        audio.play();
    }

    handlePlayPause(){
        let audio = this.template.querySelector(".my-audio");
        this.audioPlay = !this.audioPlay;
        if(this.audioPlay){
            audio.play();
        } else {
            audio.pause();
        }        
        this.template.querySelector('c-progress-bar').playPauseUpdate();
    }

    get playButtonLabel(){
        return this.audioPlay ? 'Pause' : 'Resume';
    }

    get cardImage(){
        return this.gameActivity === undefined || this.gameActivity === 'pending'? null : characterImages + '/' + this.gameActivity + '.png';
    }

    get cardClass(){
        return 'cardimage';
    }

    get showImage(){
        return this.gameActivity != undefined && this.gameActivity != 'pending' && this.gameActivity != 'intro';
    }

    get backgroundStyle(){
        let backgroundImage = characterImages + '/Intro.png';
        // return `height:40rem;opacity:.80;background-image:url(${backgroundImage})`;
        return `height:40rem;background-image:url(${backgroundImage})`;
    }
}