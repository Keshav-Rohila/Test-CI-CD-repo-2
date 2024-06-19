import { LightningElement, track, api, wire } from 'lwc';
import getAddressTypeOptions from '@salesforce/apex/AddressComponentController.getAddressTypeOptions';
// import getApiKey from '@salesforce/apex/AddressComponentController.getApiKey';
import getSearchSuggestions from '@salesforce/apex/AddressComponentController.getSearchSuggestions';
import selectLocation from '@salesforce/apex/AddressComponentController.selectLocation';
import saveAddress from '@salesforce/apex/AddressComponentController.saveAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Address extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track queryTerm;
    @track addressTypeOptions = [];
    @track showAddressTypeInput = false;
    @track searchSuggestionList = [];
    @track isLoading = false;
    @track selectedValue;
    @track address = {
        street: '',
        city: '',
        state: '',
        country: '',
        postalCode: '',
        latitude: null,
        longitude: null,
        primary: false,
        type: []
    }

    isAddressTypeRequired = true;
    showpills = true;
    // apiKey;

    @wire(getAddressTypeOptions)
    addressTypesWire({ error, data }) {
        if (data) {
            console.log('#data -> ' + JSON.stringify(data));
            this.addressTypeOptions = data.map((item, index) => ({ label: item.label, value: item.value, index: index, checked: false, show: true }));
            console.log('#address options -> ' + JSON.stringify(this.addressTypeOptions));
            this.showAddressTypeInput = true;
        }
        else if (error) {
            console.log('#error -> ' + JSON.stringify(error));
        }
    }

    handleInputChange(event){
        const label = event.currentTarget.label;
        console.log('label -> ' + label);
        if(label == 'Primary'){
            this.address.primary = event.detail.checked;
        }
        else if(label == 'Street'){
            this.address.street = event.detail.value;
        }
        else if(label == 'City'){
            this.address.city = event.detail.value;
        }
        else if(label == 'State'){
            this.address.state = event.detail.value;
        }
        else if(label == 'Country'){
            this.address.country = event.detail.value;
        }
        else if(label == 'Postal Code'){
            this.address.postalCode = event.detail.value;
        }

        console.log('this.address -> ' + JSON.stringify(this.address));
    }

    getSearchRecommendations(key) {
        getSearchSuggestions({ key: key })
            .then(result => {
                console.log('search suggestions -> ' + result);
                if(this.selectedValue != '' && this.selectedValue != null){
                    this.searchSuggestionList = JSON.parse(result).predictions.slice(0, 4);
                }
            })
            .catch(error => {
                console.log(error);
            })

    }

    handleAddressTypeSelection(event) {
        console.log('event -> ' + JSON.stringify(event.detail));
        this.address.type = [];
        event.detail.options.map(op => {
            if (op.checked) {
                this.address.type.push(op.label);
            }
        });
        console.log('selectedOptions -> ' + this.address.type);

    }

    searchSelectedLocation(query){
        selectLocation({searchKey: query})
        .then(result => {
            console.log('result -> ' + result);
            console.log('location result -> '+ result);
            const response = JSON.parse(result);
            if(response.status == 'OK'){
                const res = response.results[0];
                const formattedAddress = res.formatted_address;
                console.log('formatted Address-> ' + formattedAddress);

                // street 
                let street = JSON.parse(result).results[0].address_components.find(item => item.types.includes('route'));
                let streetNumber = JSON.parse(result).results[0].address_components.find(item => item.types.includes('street_number'));
                if(streetNumber){
                    this.address.street = streetNumber.long_name + ' ';
                }
                if(street){
                    this.address.street += street.long_name;
                }
                // city
                let city = JSON.parse(result).results[0].address_components.find(item => item.types.includes('locality'));
                if(!city){
                    city = JSON.parse(result).results[0].address_components.find(item => item.types.includes('postal_town'));
                }
                if(city){
                    this.address.city = city.long_name;
                }
                // state
                let state = JSON.parse(result).results[0].address_components.find(item => item.types.includes('administrative_area_level_1'));
                if(state){
                    this.address.state = state.long_name;
                }
                // country
                let country = JSON.parse(result).results[0].address_components.find(item => item.types.includes('country'));
                if(country){
                    this.address.country = country.long_name;
                }
                // postal code
                let postalCode = JSON.parse(result).results[0].address_components.find(item => item.types.includes('postal_code'));
                if(country){
                    this.address.postalCode = postalCode.long_name;
                }

                const location = response.results[0].geometry.location;
                if(location){
                    this.address.latitude = location.lat;
                    this.address.longitude = location.lng;
                }

                const placeid = response.results[0].place_id
                console.log('location:', JSON.stringify(location));
                console.log('Latitude:', location.lat);
                console.log('Longitude:', location.lng);
                console.log('place_id:', placeid);
                
            }
            
        })
        .catch(error => {
            console.log(error);
        })
    }

    
    handleChange(event) {

        this.selectedValue = event.target.value;
        console.log('input text -> ' + this.selectedValue);
        if (this.selectedValue != '' && this.selectedValue != null) {
            this.getSearchRecommendations(this.selectedValue);
        }
        else {
            console.log('null input');
            this.searchSuggestionList = [];
        }

    }

    handleSelection(event) {
        var selectedText = event.currentTarget.dataset.recid;
        this.selectedValue = selectedText;
        this.searchSelectedLocation(this.selectedValue);
        console.log('selected value -> ' + this.selectedValue);
        this.searchSuggestionList = [];

    }

    handleSave(){
        console.log('handle save');
        const isValid = this.validateInputs();
        console.log('isValid -> ' + isValid);
        console.log('recordid -> ' + this.recordId);
        if(isValid){
            this.isLoading = true;
            saveAddress({relatedRecId: this.recordId, addressString: JSON.stringify(this.address)})
            .then(result => {
                this.showToastMessage(this, 'success', 'Record Created',  '',  'dismissible');
                this.resetInputs();
            })
            .catch(error => {
                this.handleErrorResponse(error);
            })
            .finally(() => {
                this.isLoading = false;
            })
        }
        
    }

    showToastMessage(component,type, title, message, mode) {
        const toast = new ShowToastEvent({
            "variant": type,
            "title": title,
            "message": message,
            "mode": mode
        });
        component.dispatchEvent(toast);
    }

    validateInputs(){
        var isValid = true;
        const child = this.template.querySelector('c-custom-multi-pick-list');
        if(child){
            isValid = child.isValid();
        }
        
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return (allValid && isValid);
    }

    resetInputs(){
        this.address = {
            street: '',
            city: '',
            state: '',
            country: '',
            postalCode: '',
            latitude: null,
            longitude: null,
            primary: false,
            type: []
        }

        this.selectedValue = '';

        const child = this.template.querySelector('c-custom-multi-pick-list');
        if(child){
            child.resetSelection();
        }
    }

    handleErrorResponse(errorResponse) {
        let reducedError = this.reduceErrors(errorResponse).join(',');
        this.showToastMessage(this , 'error', 'Error encountered', reducedError, 'sticky');
    
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        console.log('#1');
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (
                        error?.body?.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        console.log('#2');
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (
                        error?.body?.fieldErrors &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        console.log('#3');
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (
                        error?.body?.output?.errors &&
                        error.body.output.errors.length > 0
                    ) {
                        console.log('#4');
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (
                        error?.body?.output?.fieldErrors &&
                        Object.keys(error.body.output.fieldErrors).length > 0
                    ) {
                        console.log('#5');
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        console.log('#6');
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        console.log('#7');
                        return error.message;
                    }
                    console.log('#8');
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }
}