import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    @api count;
    var2 = 20;

    connectedCallback(){
        // custom events
        const event = new CustomEvent(
            'dispatchinfo',
            {
                detail: {name: 'keshav', age: 22, arr: [1, 2, 3]}
            }
        );
        this.dispatchEvent(event);
    }
}