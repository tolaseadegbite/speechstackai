import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "content" ]

  showModal() {
    this.contentTarget.showModal()
  }

  close() {
    this.contentTarget.close()
  }

  closeOnClickOutside({ target }) {
    if (target.nodeName === "DIALOG") {
      this.close()
    }
  }
}