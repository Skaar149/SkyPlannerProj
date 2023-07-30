import { LightningElement, track, api } from "lwc";
import getcontactRoleListString from "@salesforce/apex/contactRoleService.getcontactRoleListString";

export default class ContactRoleListComponent extends LightningElement {
  @track filter = "";
  @api recordId;
  errorMessage;
  @track contactRoleList;
  @track contactRoleListJson;
  @track allcontactRoleListJson;
  columns = [
    { label: "Name", fieldName: "contactName" },
    { label: "Phone", fieldName: "contactPhone", type: "phone" },
    { label: "Email", fieldName: "contactEmail", type: "email" },
    { label: "Roles", fieldName: "contactRoles", type:"contactRoleListType"}
  ];

  connectedCallback() {   
    getcontactRoleListString({ AccId: this.recordId, Filter: this.filter })
      .then((result) => {
        console.log("entro getcontactRoleListString ");
        console.log("getcontactRoleListString " + JSON.stringify(result));
        this.contactRoleList = result;
      })
      .catch((error) => {
        this.errorMessage = error;
        this.contactRoleListJson = undefined;
      });
  }

  handelSearchKey(event) {
    this.filter = event.target.value;
    this.connectedCallback();
  }
}
