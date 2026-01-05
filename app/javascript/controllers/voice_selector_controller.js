import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label", "modal"]

  // Open the native <dialog>
  openModal() {
    this.modalTarget.showModal()
  }

  // Close the native <dialog>
  closeModal() {
    this.modalTarget.close()
  }

  // Called when a user clicks a radio button in the library
  select(event) {
    // 1. Update the hidden input (Source of Truth)
    this.inputTarget.value = event.params.id
    
    // 2. Update the visible button label
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = event.params.name
    }

    // 3. Close modal automatically for better UX
    this.closeModal()
  }
}