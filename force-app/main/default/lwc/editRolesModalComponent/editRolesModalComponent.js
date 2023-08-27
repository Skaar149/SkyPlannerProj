import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllRoleList from "@salesforce/apex/ContactRolesModalService.getAllRoleList";
import getRoleByContact from "@salesforce/apex/ContactRolesModalService.getRoleByContact";
import updateRoleByContact from "@salesforce/apex/ContactRolesModalService.updateRoleByContact";

export default class EditRolesModalComponent extends LightningElement {
  @api showModal;
  @api contactId;
  @api contactName;
  @api contactRoles;
  @track options = [];
  @track values = [];
  initialValues = [];
  finalValues = [];
  updateRolesResult = "";
  cId = "";
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
        const toastTitle  = 'Unexpected Error';
        const msg = 'Method getAllRoleList throw Exception: '+ error;
        const variant = 'error';
        this.saveSpinner = false;
        this.showNotification(toastTitle, msg, variant);
      });

    //getRoleByContact
    getRoleByContact({ contactId: cId })
      .then((result) => {
        this.values = result;
        this.initialValues = result;
        this.finalValues = result;
        this.saveSpinner = false;
      })
      .catch((error) => {
        const toastTitle  = 'Unexpected Error';
        const msg = 'Method getRoleByContact throw Exception: '+ error;
        const variant = 'error';
        this.saveSpinner = false;
        this.showNotification(toastTitle, msg, variant);
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
       const toastTitle = 'Edit Roles';
        if (result === "OK") {
          this.dispatchEvent(new CustomEvent("positive"));
          const msg = 'The roles were successfully edited for the Contact: '+ this.contactName;    
          const variant = 'success';          
          this.showNotification(toastTitle, msg, variant);
        } else {
          this.dispatchEvent(new CustomEvent("negative"));
          const msg = 'Roles not successfully edited for Contact: '+ this.contactName + '. Error message: ' + result;    
          const variant = 'error';  
          this.showNotification(toastTitle, msg, variant);
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

  showNotification(toastTittle, msg, toastVariant) {
    const evt = new ShowToastEvent({
        title: toastTittle,
        message: msg,
        variant: toastVariant,
    });
    this.dispatchEvent(evt);
}
}
