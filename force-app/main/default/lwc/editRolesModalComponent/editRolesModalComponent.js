import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllRoleList from "@salesforce/apex/editRolesModalService.getAllRoleList";
import getRoleByContact from "@salesforce/apex/editRolesModalService.getRoleByContact";
import updateRoleByContact from "@salesforce/apex/editRolesModalService.updateRoleByContact";

export default class EditRolesModalComponent extends LightningElement {
  @api showModal;
  @api contactId;
  @api contactName;
  @api contactRoles;
  @track options = [];
  @track values = [];
  initialValues = [];
  finalValues = [];
  errorMessage = undefined;
  updateRolesResult = "";
  cId = "";
  toastTitle = 'Edit Roles';
  toastMessage = '';
  toastVariant = '';
  @track saveSpinner = false;

  @api handleOnInitModal(cId) {
    this.saveSpinner = true;
    this.cId = cId;
    //getAllRoleList
    getAllRoleList()
      .then((result) => {
        this.options = result;
      })
      .catch((error) => {
        this.errorMessage = error;
        this.contactRoleListJson = undefined;
      });

    //getRoleByContact
    getRoleByContact({ contactId: cId })
      .then((result) => {
        this.values = result;
        this.initialValues = result;
        this.saveSpinner = false;
      })
      .catch((error) => {
        this.errorMessage = error;
        this.contactRoleListJson = undefined;
        this.saveSpinner = false;
      });
  }

  handlePositive() {
    this.saveSpinner = true;
    this.options = [];
    this.values = [];
    if (this.finalValues !== this.initialValues) {
      //updateRoleByContact
      updateRoleByContact({
        contactId: this.cId,
        initialRoles: this.initialValues,
        finalRoles: this.finalValues
      }).then((result) => {
        this.toastTitle = 'Edit Roles';
        if (result === "OK") {
          this.dispatchEvent(new CustomEvent("positive"));
          this.toastMessage = 'The roles were successfully edited for the Contact: '+ this.contactName;    
          this.toastVariant = 'success';          
          this.showNotification();
        } else {
          this.dispatchEvent(new CustomEvent("negative"));
          this.toastMessage = 'Roles not successfully edited for Contact: '+ this.contactName + '. Error message: ' + result;    
          this.toastVariant = 'error';  
          this.showNotification();
        }
        this.saveSpinner = false;
      });
    } else {
      this.dispatchEvent(new CustomEvent("close"));
    }
  }

  handleNegative() {
    this.options = [];
    this.values = [];
    this.dispatchEvent(new CustomEvent("close"));
  }

  handleClose() {
    this.options = [];
    this.values = [];
    this.dispatchEvent(new CustomEvent("close"));
  }

  handleChangeDuaListbox(event) {
    const selectedOptionsList = event.detail.value;
    this.finalValues = selectedOptionsList;
  }

  showNotification() {
    const evt = new ShowToastEvent({
        title: this.toastTitle,
        message: this.toastMessage,
        variant: this.toastVariant,
    });
    this.dispatchEvent(evt);
}
}
