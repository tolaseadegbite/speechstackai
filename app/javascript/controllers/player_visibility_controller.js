import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="player-visibility"
export default class extends Controller {
  static targets = [ "playerContainer" ]

  connect() {
    // You could add logic here if needed when the controller first connects.
    // For this case, we don't need anything.
  }

  show() {
    // This action simply removes the 'hidden' attribute from our target.
    this.playerContainerTarget.hidden = false
  }
}