import { LightningElement, wire, track } from 'lwc';
import getPlants from '@salesforce/apex/StrawberryController.getPlants';
import clonePlant from '@salesforce/apex/StrawberryController.clonePlant';
import getVarietyList from '@salesforce/apex/StrawberryController.getVarietyList';
import getStateList from '@salesforce/apex/StrawberryController.getStateList';
import waterThePlant from '@salesforce/apex/StrawberryController.waterThePlant';
import harvestPlant from '@salesforce/apex/StrawberryController.harvestPlant';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import object_plant from '@salesforce/schema/Plant__c';
import field_name from '@salesforce/schema/Plant__c.Name';
import field_height from '@salesforce/schema/Plant__c.Height__c';
import field_line from '@salesforce/schema/Plant__c.Line__c';
import field_variety from '@salesforce/schema/Plant__c.Variety__c';
import field_plantingdate from '@salesforce/schema/Plant__c.PlantingDate__c';
import field_wateringdate from '@salesforce/schema/Plant__c.WateringDate__c';
import field_state from '@salesforce/schema/Plant__c.State__c';
import field_varietyripening from '@salesforce/schema/Plant__c.VarietyRipening__c';
import field_harvest from '@salesforce/schema/Plant__c.Harvest__c';

export default class PlantList extends LightningElement {
    @track plants;
    @track _wiredPlants = [];
    varietyList;
    stateList;
    selectedPlant = null;
    isNew = false;
    isEdit = false;
    isView = false;
    isHarvest = false;

    // fields 
    fieldHeight = field_height;
    fieldLine = field_line;
    fieldVariety = field_variety;
    fieldPlantingDate = field_plantingdate;
    fieldWateringDate = field_wateringdate;
    fieldState = field_state;
    fieldVarietyRipening = field_varietyripening;
    fieldHarvest = field_harvest;

    // filters:
    filterMinHeight = 0;
    filterMaxHeight = 30;
    _filterVarieties = [];
    _filterState = [];

    get filtersToApex() {
        var filters =
        {
            filterMinHeight: this.filterMinHeight,
            filterMaxHeight: this.filterMaxHeight,
            filterVarieties: this.filterVarieties,
            filterState: this.filterState
        };
        return filters;
    }

    get filterVarieties() {
        return this._filterVarieties.length ? this._filterVarieties : null;
    }
    get filterState() {
        return this._filterState.length ? this._filterState : null;
    }

    handleFilterReset() {
        this.filterMinHeight = 0;
        this.filterMaxHeight = 30;
        // this.filterVarieties = [];
        // this.filterState = [];
        console.log('reset:');
        var arrayLB = this.template.querySelectorAll('lightning-dual-listbox');

        for (let i = 0; i < arrayLB.length; i++) {
            console.log(arrayLB[i].value.originalTarget);
            // arrayLB[i].value = null;
        }


        // this.filterVarieties = [];
        // this.filterState = [];
        // refreshApex(this._wiredPlants);
    }

    // LOAD APEX 

    @wire(getPlants, { filtersToApex: '$filtersToApex' })
    retrievePlants(wireResult) {
        const { data, error } = wireResult;
        this._wiredPlants = wireResult;
        console.log('data? ' + data);
        if (data) {
            console.log("OppData", data);
            this.plants = data;
        }
        if (error) {
            console.error(error);
        }
    }

    @wire(getVarietyList)
    wiredGetVarietyList({ data }) {
        if (data) {
            let options = [];
            for (var key in data) {
                console.log('Varieties: ' + JSON.stringify(data));
                options.push({ label: " " + data[key], value: data[key] });
            }
            this.varietyList = options;
            console.log(this.filtersToApex);
        }
    }
    @wire(getStateList)
    wiredGetStateList({ data }) {
        if (data) {
            let options = [];
            for (var key in data) {
                console.log('States: ' + JSON.stringify(data));
                options.push({ label: " " + data[key], value: data[key] });
            }
            this.stateList = options;
        }
    }

    objectplant = object_plant;
    myFields = [field_variety, field_height, field_line, field_plantingdate, field_state, field_wateringdate, field_harvest];

    // selection

    handleSelection(event) {
        this.selectedPlant = this.plants.find(plant__c => plant__c.Id === event.detail);
        this.isNew = false;
        this.isView = true;
        this.isEdit = false;
    }

    get selectedPlantAge() {
        if (this.selectedPlant) {
            return Math.round((new Date() - new Date(this.selectedPlant.PlantingDate__c)) / 86400000);
        }
    }

    get isSelected() {
        return this.selectedPlant ? true : false;
    }

    // SLOT ACTIONS BUTTONS

    handleCloseItem() {
        this.selectedPlant = null;
        this.isNew = false;
        this.isEdit = false;
        this.isView = false;
    }

    handleCloneItem() {
        clonePlant({ recordId: this.selectedPlant.Id }).then(response => {
            refreshApex(this._wiredPlants);
        }).catch(error => {
            console.log('Error:' + error.body.message);
        });
    }

    handleDeleteItem() {

        const recordId = this.selectedPlant.Id;
        this.selectedPlant = null;

        deleteRecord(recordId)
            .then(() => {
                this.showMessage('Success', 'Record deleted', 'success')
                refreshApex(this._wiredPlants);

            })
            .catch(error => {
            });

    }

    handleFilterSetup(event) {

        if (event.target.label === "Min height") {
            this.filterMinHeight = event.target.value;
        }
        else if (event.target.label === "Max height") {
            this.filterMaxHeight = event.target.value;
        }
        else if (event.target.label === "Varieties") {
            this._filterVarieties = event.detail.value;
        }
        else if (event.target.label === "State") {
            this._filterState = event.detail.value;
        }
    }


    // FORM BUTTONS

    get isDry() {
        if (this.selectedPlant) {
            var frequency = 0;
            var plantAge = new Date() - new Date(this.selectedPlant.PlantingDate__c);
            if (plantAge < 1209600000) {
                frequency = 21600000; // if plantAge < 2 weeks
            }
            else if (plantAge >= 1209600000) {
                frequency = 259200000; // if plantAge >= 2 weeks
            }
            return new Date() - new Date(this.selectedPlant.WateringDate__c) > frequency;
        }
        else {
            return false;
        }

    }

    get isReady() {
        if (this.selectedPlant) {
            return (Math.round((new Date() - new Date(this.selectedPlant.PlantingDate__c)) / 86400000) >= this.selectedPlant.VarietyRipening__c) && this.selectedPlant.State__c === 'Ripe';
        }
    }

    handleWatering() {
        const selectedPlantId = this.selectedPlant.Id;
        waterThePlant({ recordId: selectedPlantId })
            .then(result => {
                this.selectedPlant = result;
                refreshApex(this._wiredPlants);
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleCreateItem() {
        this.isNew = true;
        this.selectedPlant = null;
        this.isView = false;
        this.isEdit = false;
    }

    handleEditItem() {
        this.isEdit = true;
        this.isView = false;
        this.isNew = false;
    }

    handleCloseEditItem() {
        this.isEdit = false;
        this.isView = true;
        this.isNew = false;
    }

    handleHarvest() {
        this.isHarvest = true;
    }

    handleHarvestSuccess() {
        const harvestWeight = this.selectedPlant.Harvest__c;
        const selectedPlantId = this.selectedPlant.Id;
        harvestPlant({ recordId: selectedPlantId })
            .then(() => {
                refreshApex(this._wiredPlants);
                this.showMessage('Success', 'Harvest is ' + harvestWeight + ' kg. Plant is in process.', 'success');
                this.isView = false;
                this.isHarvest = false;
                this.selectedPlant = null;
            })
            .catch(error => {
                this.error = String.valueOf(error);
                this.showMessage(this.error, this.error, 'error');
            });
    }

    handleCreateItemSuccess() {
        refreshApex(this._wiredPlants);
        console.log('success');
        this.isNew = false;
        this.isEdit = false;
        this.isView = false;
    }

    handleEditItemSuccess() {
        refreshApex(this._wiredPlants);
        this.isNew = false;
        this.isEdit = false;
        this.isView = true;
    }

    showMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

}