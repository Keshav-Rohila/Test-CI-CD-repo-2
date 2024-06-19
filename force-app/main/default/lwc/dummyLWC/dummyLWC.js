import { LightningElement, wire, api, track } from 'lwc';

export default class DummyLWC extends LightningElement {
    @api recordId;
    @track var1 = 10;
    dummy;

    arr = [{key: 1, name:'arihant'}, {key: 2, name:'abhishek'}, {key: 3, name:'chirag'}, {key: 4, name:'prabal'}, {key: 5, name:'rishika'}];

    handleDispatch(event){
        let value = event.detail;
        let name = value.name;
        let age = value.age;
        this.dummy = JSON.stringify(value);
        this.arr.push({
            key: 6,
            name: 'new joinee'
        });
    }
    
}