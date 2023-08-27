import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createRole from "@salesforce/apex/RolesService.createRole";

export default class RolesCreationModal extends LightningElement {
  @api showCreateRoleModal;
  @track nameRolePreview;
  @track colorStyleRole;
  @track isLoading = false;
  nameRole;
  colorRole;
  nameColorWhite = false;

  connectedCallback() {
    this.oninit();
  }

  handlePositive() {
    if (this.nameRole === "") {
      const toastTitle = "Invalid Name";
      const msg = "Please enter a Role name.";
      const variant = "warning";
      this.showNotification(toastTitle, msg, variant);
    } else if (this.colorRole === "") {
      const toastTitle = "Invalid Color";
      const msg = "Please enter a Role color.";
      const variant = "warning";
      this.showNotification(toastTitle, msg, variant);
    } else {
      this.isLoading = true;
      createRole({
        name: this.nameRole,
        color: this.colorRole,
        style: this.colorStyleRole
      })
        .then((result) => {
          if (result === "OK") {
            const toastTitle = "Create Role";
            const msg = this.nameRole + " Role was created successfully.";
            const variant = "success";
            this.showNotification(toastTitle, msg, variant);
            this.handleClose();
          } else if (result === "Invalid Name") {
            const toastTitle = "Invalid Name";
            const msg =
              this.nameRole +
              " Role is invalid because the name is repeated. Please enter a different name.";
            const variant = "warning";
            this.showNotification(toastTitle, msg, variant);
          } else {
            const toastTitle = "Invalid Color";
            const msg =
              "Color Role is invalid because the Color is repeated. Please enter a different Color.";
            const variant = "warning";
            this.showNotification(toastTitle, msg, variant);
          }
          this.isLoading = false;
        })
        .catch((error) => {
          const toastTitle = "Unexpected Error";
          const msg = "Create Role throw Exception: " + error;
          const variant = "error";
          this.saveSpinner = false;
          this.showNotification(toastTitle, msg, variant);
          this.isLoading = false;
        });
    }
  }

  handleColorChange(event) {
    this.colorRole = event.target.value;
    this.colorStyleRole = "background-color: " + this.colorRole;
  }

  handleNameChange(event) {
    this.nameRole = event.target.value;
    this.nameRolePreview = this.nameRole;
  }

  handleNameColor() {
    var colorFont = "Color: #FFFFFF;";
    this.nameColorWhite = !this.nameColorWhite;
    const colorBackground = "background-color: " + this.colorRole;
    if (!this.nameColorWhite) {
      colorFont = "Color: #000000;";
    }
    this.colorStyleRole = colorFont + colorBackground;
  }

  oninit() {
    this.nameColorWhite = false;
    this.nameRolePreview = "";
    this.nameRole = "";
    this.colorRole = "";
    this.colorStyleRole = "";
  }

  handleClose() {
    this.oninit();
    this.dispatchEvent(new CustomEvent("closecreaterole"));
  }

  showNotification(toastTittle, msg, toastVariant) {
    const evt = new ShowToastEvent({
      title: toastTittle,
      message: msg,
      variant: toastVariant,
      mode: "sticky"
    });
    this.dispatchEvent(evt);
  }
}
