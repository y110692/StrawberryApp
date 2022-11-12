import { LightningElement, api } from 'lwc';

export default class PlantItem extends LightningElement {

    @api plant;
    handleSelection(event) {
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('select', { detail: this.plant.Id }))
    }

    get isDry() {
        var frequency = 0;
        var plantAge = new Date() - new Date(this.plant.PlantingDate__c);
        if (plantAge < 1209600000) {
            frequency = 21600000; // if plantAge < 2 weeks
        }
        else if (plantAge >= 1209600000) {
            frequency = 259200000; // if plantAge >= 2 weeks
        }
        return new Date() - new Date(this.plant.WateringDate__c) > frequency;
    }

    get isReady() {

        var plantAge = (new Date() - new Date(this.plant.PlantingDate__c)) / 86400000;
        return (plantAge >= this.plant.VarietyRipening__c) && this.plant.State__c === 'Ripe';
    }
}