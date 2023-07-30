import LightningDatatable from 'lightning/datatable';
import contactRoleListTemplate from './contactRoleListTemplate.html'
export default class CustomDataTableComponent extends LightningDatatable {
    static customTypes = {
        contactRoleListType: {
            template: contactRoleListTemplate
        }
    };
}