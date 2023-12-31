import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getcontactRolesList from "@salesforce/apex/ContactRolesService.getcontactRolesList";

const cols = [
  { label: "Name", fieldName: "contactName" },
  { label: "Phone", fieldName: "contactPhone", type: "phone" },
  { label: "Email", fieldName: "contactEmail", type: "email" },
  { label: "Roles", fieldName: "contactRoles", type: "contactRoleListType" },
  {
    type: "button",
    fixedWidth: 150,
    typeAttributes: {
      label: "Add | Remove",
      name: "Add | Remove",
      variant: "neutral",
      value: "Add | Remove"
    }
  }
];

export default class ContactRoleListComponent extends LightningElement {
  @track filter = "";
  @api recordId;
  @track contactRoleList;
  editRolesIconName = "utility:preview";
  editRolesButtonLabel = "Edit Roles";
  editRolesColumnVisible = false;
  @track columns = cols;
  @track isLoading = false;

  //editRolesModalFields
  ModalShow = false;
  ContactId = "";
  ContactName = "";
  ContactRoles = [];

  //createRoleModal
  showCreateRoleModal = false;

  connectedCallback() {
    this.onInit();
  }

  onInit() {
    this.isLoading = true;
    getcontactRolesList({ AccId: this.recordId, Filter: this.filter })
      .then((result) => {
        this.contactRoleList = result;
        this.isLoading = false;
      })
      .catch((error) => {
        const toastTitle = "Unexpected Error";
        const msg = "Method getcontactRolesList throw Exception: " + error;
        const variant = "error";
        this.saveSpinner = false;
        this.showNotification(toastTitle, msg, variant);
        this.isLoading = false;
      });
    //Check for state of the dynamic column Add | Remove
    if (!this.editRolesColumnVisible) {
      this.columns = cols.filter((col) => col.typeAttributes === undefined);
    } else {
      this.columns = cols;
    }
  }

  handelSearchKey(event) {
    this.filter = event.target.value;
    this.connectedCallback();
  }

  handleEditRolesClick() {
    //change to visible or hide
    this.editRolesColumnVisible = !this.editRolesColumnVisible;

    // if the current icon-name is `utility:preview` then change it to `utility:hide`
    if (this.editRolesIconName === "utility:preview") {
      this.editRolesIconName = "utility:hide";
      this.editRolesButtonLabel = "Hide Edit Roles";
    } else {
      this.editRolesIconName = "utility:preview";
      this.editRolesButtonLabel = "Edit Contact Roles";
    }

    if (!this.editRolesColumnVisible) {
      this.columns = cols.filter((col) => col.typeAttributes === undefined);
    } else {
      this.columns = cols;
    }
  }

  callRowAction(event) {
    const actionName = event.detail.action.name;
    if (actionName === "Add | Remove") {
      this.ContactId = event.detail.row.contactId;
      this.ContactName = event.detail.row.contactName;
      this.ContactRoles = event.detail.row.contactRoles;
      this.ModalShow = true;
      this.template
        .querySelector("c-edit-roles-modal-component")
        .handleOnInitModal(this.ContactId);
    }
  }

  closeModal() {
    this.ModalShow = false;
  }

  closeModalAndRefresh() {
    this.ModalShow = false;
    this.onInit();
  }

  handleCreateRoleClick() {
    this.showCreateRoleModal = !this.showCreateRoleModal;
  }
  
  closeCreateRoleModal(){
    this.showCreateRoleModal = false;
  }

  showNotification(toastTittle, msg, toastVariant) {
    const evt = new ShowToastEvent({
      title: toastTittle,
      message: msg,
      variant: toastVariant
    });
    this.dispatchEvent(evt);
  }
}
