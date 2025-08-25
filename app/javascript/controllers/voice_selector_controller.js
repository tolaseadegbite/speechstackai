// app/javascript/controllers/voice_selector_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="voice-selector"
export default class extends Controller {
  static targets = ["input", "select"]

  connect() {
    // Ensure all selects match the hidden input's value on load
    this.syncAllSelects(this.inputTarget.value)
  }

  // This action is called whenever ANY of the select menus change
  select(event) {
    const selectedValue = event.currentTarget.value
    
    // 1. Update the single hidden input field. This is the new "source of truth".
    this.inputTarget.value = selectedValue
    
    // 2. Sync the OTHER select menu to match the one that was just changed.
    this.syncAllSelects(selectedValue)
  }

  // Helper to make all visible select menus show the same value
  syncAllSelects(value) {
    this.selectTargets.forEach(select => {
      if (select.value !== value) {
        select.value = value
      }
    })
  }
}