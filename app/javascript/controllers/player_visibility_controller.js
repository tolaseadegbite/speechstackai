import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="player-visibility"
export default class extends Controller {
  static targets = [ "playerContainer", "collapsible" ]

  connect() {
    // This is the crucial change. We are now targeting the correct parent container.
    this.contentArea = document.querySelector(".sidebar-layout");
  }

  show() {
    this.playerContainerTarget.hidden = false;
    this.playerContainerTarget.classList.remove('is-minimized');
    this.updateBottomPadding();
  }

  hide() {
    this.playerContainerTarget.hidden = true;
    this.clearBottomPadding();
  }

  minimize() {
    this.playerContainerTarget.classList.add('is-minimized');
    // Recalculate the padding for the new, smaller player height.
    requestAnimationFrame(() => this.updateBottomPadding());
  }

  expand() {
    this.playerContainerTarget.classList.remove('is-minimized');
    // Recalculate the padding for the full player height.
    requestAnimationFrame(() => this.updateBottomPadding());
  }

  // --- Helper Methods ---

  updateBottomPadding() {
    // Guard clause to ensure the content area was found.
    if (!this.contentArea || this.playerContainerTarget.hidden) return;

    // Get the current height of the player.
    const playerHeight = this.playerContainerTarget.offsetHeight;

    // Apply this height as padding-bottom to the entire sidebar-layout container.
    this.contentArea.style.paddingBottom = `${playerHeight}px`;
  }

  clearBottomPadding() {
    if (!this.contentArea) return;
    
    // Remove the padding when the player is hidden.
    this.contentArea.style.paddingBottom = '0';
  }
}