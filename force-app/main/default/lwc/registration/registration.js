import { LightningElement, api } from 'lwc';

export default class Registration extends LightningElement {
    @api gameSettings;
    @api gameInfo;

    get shortMobileAppUrl() {
        if (this.gameSettings) {
            return this.gameSettings.playerAppUrlMinified.replace(
                'https://',
                ''
            );
        }
        return '';
    }
}