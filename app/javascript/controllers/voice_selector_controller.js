import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="voice-selector"
export default class extends Controller {
  static targets = ["input"]

  // This action is called when any radio button card is selected.
  select(event) {
    // It updates the single hidden input field, which is the "source of truth" for the form.
    this.inputTarget.value = event.currentTarget.value
  }
}