import { LightningElement, track, wire, api} from 'lwc';
import getAllContactRole from "@salesforce/apex/contactRoleService.getcontactRole";

export default class ContactRoleListComponent extends LightningElement {
    @track filter = '';
    @api recordId;
    errorMessage; 
    @track contactRoleList; 
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
        { label: 'Email', fieldName: 'Email', type: 'email' }
    ];      

    handelSearchKey(event){
        this.filter = event.target.value;
    }

    @wire(getAllContactRole , {RecordId: this.recordId , Filter : '$filter'})    
    getcontactRoleList({ error, data }) {
        if (data) {  
            this.contactRoleList = data;     
        } else if (error) {
            this.contactRoleList = data;   
            this.errorMessage = error.body.message;
        }
    }

}