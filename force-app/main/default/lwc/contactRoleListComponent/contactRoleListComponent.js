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
        this.contactRoleListJson =  JSON.parse(result[0]);
        console.log(
          "this.contactRoleListJson " +
          JSON.stringify(this.contactRoleListJson)
        );
        console.log(
          "this.contactRoleListJson [0].contactName " +
            JSON.stringify(
              this.contactRoleListJson.contactName
            )
        );
        console.log('antes del foreach ' );
        this.contactRoleList = [];
        result.forEach(contactRole =>{
          this.contactRoleList.push(JSON.parse(contactRole))
          console.log('foreach element ' + JSON.stringify(JSON.parse(contactRole)))
      });
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
