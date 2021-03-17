import { LightningElement, api, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor'

export default class Tile extends LightningElement {
    @api card;
    @track isSelected = false;

    formFactor = FORM_FACTOR;

    showLogs(message){
        // if(!this.isGuestuser){
            window.console.log('cardTile: ', message);
        // }
    }

    get imageWidth(){
        let width = 120
        if(this.formFactor === 'Small'){
            width = 60;
        } 
        else if(this.formFactor === 'Medium'){
            width = 80;
        }
        return width;
    }

    get imageHeight(){
        let height = 150;
        if(this.formFactor === 'Small'){
            height = 75;
        } 
        else if(this.formFactor === 'Medium'){
            height = 100;
        }
        return height;       
    }    

    tileClick() {
        this.isSelected = !this.isSelected;
        let eventDetails = {id:this.card.id, isSelected:this.isSelected, name:this.card.name};

        const event = new CustomEvent('cardselected', {
            // detail contains only primitives
            detail: eventDetails
        });
        this.showLogs('ctileClick Event, Details: ' + JSON.stringify(eventDetails));
        // Fire the event from c-tile
        this.dispatchEvent(event);
    }
}