import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="player-visibility"
export default class extends Controller {
  static targets = [ "playerContainer", "collapsible" ]

  // This action shows/hides the entire player.
  toggle() {
    const isHidden = this.playerContainerTarget.hidden

    if (isHidden) {
      // If hiding, always show in the expanded state.
      this.playerContainerTarget.classList.remove('is-minimized')
      this.playerContainerTarget.hidden = false
    } else {
      // If showing, just hide it.
      this.playerContainerTarget.hidden = true
    }
  }

  // --- THE FIX: Replace toggleMinimize with two specific actions ---

  // Action to specifically minimize the player.
  // Called by the chevron-down button.
  minimize() {
    this.playerContainerTarget.classList.add('is-minimized')
  }

  // Action to specifically expand the player.
  // Called by the progress bar.
  expand() {
    this.playerContainerTarget.classList.remove('is-minimized')
  }
}