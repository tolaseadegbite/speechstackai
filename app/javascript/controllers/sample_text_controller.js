import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "resetButton"]

  connect() {
    // Check state on load (in case browser restores text or user goes back)
    this.handleInput()
  }

  // Called whenever the user types or pastes text
  handleInput() {
    const hasText = this.inputTarget.value.length > 0
    
    // Toggle the hidden attribute based on text presence
    if (this.hasResetButtonTarget) {
      this.resetButtonTarget.hidden = !hasText
    }
  }

  // Called when the reset button is clicked
  resetForm() {
    // 1. Clear the value
    this.inputTarget.value = ""
    
    // 2. Hide the button immediately
    this.handleInput()
    
    // 3. Dispatch an input event so the Character Counter updates to "0"
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    
    // 4. Return focus to the input for better UX
    this.inputTarget.focus()
  }

  // Your existing logic for clicking sample text buttons
  insert(event) {
    this.inputTarget.value = event.params.text
    
    // Important: Manually trigger the input logic so the reset button appears
    this.handleInput()
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  // Your existing logic for hovering sample texts (optional)
  showPlaceholder(event) {
    this.originalPlaceholder = this.inputTarget.placeholder
    this.inputTarget.placeholder = event.params.text
  }

  hidePlaceholder() {
    this.inputTarget.placeholder = this.originalPlaceholder || ""
  }
}