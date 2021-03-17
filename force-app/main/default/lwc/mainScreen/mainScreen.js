import { LightningElement, track, api } from 'lwc';
import getGameDetails from '@salesforce/apex/GameController.getGameDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TheGame extends LightningElement {
    @api cardBack;
    @api gameId;

    @api gameStageUpdate(newStage){
        if(newStage === 'revealCards'){
            this.fetchGameInfo();
        }
    }

    @track players = [];
    @track centerCards = [];
    @track votedPlayers = {};

    showLogs(message){
        window.console.log('mainScreen: ', message);
    }
    
    connectedCallback() {
        this.fetchGameInfo();
    }

    fetchGameInfo(){
        this.showLogs('in fetchGameInfo');
        if(this.gameId != undefined){
            getGameDetails({gameId : this.gameId})
            .then(result =>{
                if (result) {
                    this.players = result.players;
                    this.centerCards = result.centerCards;
                    this.showLogs('fetchGame, players = ' + JSON.stringify(this.players));
                    this.showLogs('fetchGame, centerCards = ' + JSON.stringify(this.centerCards));
                }
            })
            .catch(error => {
                this.showLogs('theGame fetchGameInfo-------error-------------'+error);
                window.console.log(error);
            })
            .finally(() => {
                this.updateVotedPlayers();
            });
        }
    }

    updateVotedPlayers(){
        let vPlayers = {};
        this.players.forEach(function (player){
            vPlayers[player.id] = false;
        });
        this.votedPlayers = vPlayers;
        // if(this.votedPlayers != undefined){
        //     this.remainingVoteCheck();
        // }
    }

    remainingVoteCheck(){
        let votingFinished = true;
        this.showLogs('votedPlayers = ' + JSON.stringify(this.votedPlayers));
        let playerIds = Object.keys(this.votedPlayers);
        this.showLogs('playerIds = ' + playerIds);
        let votedPlayers = this.votedPlayers;
        for(let i = 0; i < playerIds.length; i++){
            let playerId = playerIds[i];
            this.showLogs('remainingVoteCheck ' + this.votedPlayers[playerId]);
            if(!this.votedPlayers[playerId]) {
                votingFinished = false;
            }
        }
        // Object.keys(this.votedPlayers).forEach(function(player){
        //     this.showLogs('remainingVoteCheck ' + votedPlayers[player]);
            
        // })
        this.votingUpdateEvent(votingFinished);
    }

    votingUpdateEvent(votingFinished){
        let eventDetails = {votingFinished:votingFinished};

        const event = new CustomEvent('votingupdate', {
            // detail contains only primitives
            detail: eventDetails
        });
        this.showLogs('votingUpdate Event, Details: ' + JSON.stringify(eventDetails));
        // Fire the event from c-tile
        this.dispatchEvent(event);
    }

    handlePlayerVote(event){
        this.showLogs('handlePlayerVote');
        let detail = event.detail;
        this.votedPlayers[detail.id] = detail.voted;
        this.showLogs('votes = ' + JSON.stringify(this.votedPlayers));
        this.remainingVoteCheck();
    }
}