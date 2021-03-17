import { LightningElement, track } from 'lwc';

import getCharacterList from '@salesforce/apex/GameController.getCharacterList';
// import gameSetup from '@salesforce/apex/GameController.gameSetup';

export default class GameSetup extends LightningElement {
    @track characterList = [];
    @track newGame;
    @track selectedCards = [];

    showLogs(message){
        window.console.log('gameSetup: ', message);
    }

    connectedCallback(){
        getCharacterList({})
        .then(result => {
            window.console.log('%c connectedCallback result:', 'color: blue');
            window.console.table(result);
            if (result) {
                this.characterList = this.sortByName(result);
            }
        })
        .catch(error => {
            this.showLogs('connectedCallback: -------error-------------'+error);
            window.console.log(error);
        })
        .finally(() => {
            this.loading = false;
        });
    }

    handleTileClick(event) {
        let detail = event.detail;
        this.showLogs('handleTileClick detail: ' + JSON.stringify(detail));       
        if(detail.isSelected){
            this.selectedCards.push(detail.id);
        } else {            
            this.selectedCards = this.selectedCards.filter(function(value, index, arr){ return value != detail.id;});
        }
        this.updateSelectedCharacters();
    }

    updateSelectedCharacters() {
        let eventDetails = {selectedCharacters:this.selectedCards};

        const event = new CustomEvent('updateselectedcharacters', {
            // detail contains only primitives
            detail: eventDetails
        });
        this.showLogs('updateCount Event, Details: ' + JSON.stringify(eventDetails));
        // Fire the event from c-tile
        this.dispatchEvent(event);
    }

    sortByName(charcterList){
        return charcterList.sort(function(a,b){
            if(a.name < b.name) return -1;
            if(a.name > b.name) return 1;
            return 0;
        })
    }

    // handleCreateGame(event) {
    //     this.showLogs('gameSetup2 handleCreateGame');
    //     // gameSetup({playerCount : this.playerCount, selectedCards : this.selectedCards})
    //     gameSetup({selectedCards : this.selectedCards})
    //     .then(result => {
    //         this.showLogs('handleCreateGame result = '+ result);
    //         if (result) {
    //             let eventDetails = {gameId:result.Id, gameCode:result.Game_Code__c, gameStatus:result.Status__c, cardBackImage:result.Card_Back_Image__c};

    //             const event = new CustomEvent('prepgame', {
    //                 // detail contains only primitives
    //                 detail: eventDetails
    //             });
    //             this.showLogs('handleCreateGame: inside prepGame event');
    //             // Fire the event from c-gameSetup
    //             this.dispatchEvent(event);
    //         }
    //     })
    //     .catch(error => {
    //         this.showLogs('handleCreateGame -------error-------------'+error);
    //         window.console.log(error);
    //     })
    //     .finally(() => {
    //         this.loading = false;
    //     });
    // }
}