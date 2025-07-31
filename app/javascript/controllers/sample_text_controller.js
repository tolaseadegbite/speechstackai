import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sample-text"
export default class extends Controller {
  static targets = [ "output" ]

  connect() {
    // When the controller first connects, save the original placeholder text.
    this.originalPlaceholder = this.outputTarget.placeholder
  }

  // --- ACTIONS ---

  // Fires when the mouse hovers over a button.
  showPlaceholder(event) {
    const textToPreview = event.params.text
    this.outputTarget.placeholder = textToPreview
  }

  // Fires when the mouse leaves a button.
  hidePlaceholder() {
    this.outputTarget.placeholder = this.originalPlaceholder
  }

  // Fires when a button is clicked.
  insert(event) {
    const textToInsert = event.params.text
    this.outputTarget.value = textToInsert

    // Optional but good practice: ensure other scripts see the change.
    this.outputTarget.dispatchEvent(
      new Event('input', { bubbles: true })
    )
  }
}