import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "spinner"]

  trigger() {
    this.inputTarget.click()
  }

  async upload(event) {
    const file = event.target.files[0]
    if (!file) return

    this.showLoading()

    const formData = new FormData()
    formData.append("pdf_file", file)
    
    const token = document.querySelector('meta[name="csrf-token"]').content

    try {
      const response = await fetch("/pdf_extractions", {
        method: "POST",
        headers: { 
          "X-CSRF-Token": token,
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        this.insertText(data.text)
      } else {
        console.error("PDF Upload failed")
      }
    } catch (error) {
      console.error("Error uploading PDF:", error)
    } finally {
      this.hideLoading()
      this.inputTarget.value = ""
    }
  }

  insertText(text) {
    if (!this.hasOutputTarget) return
    this.outputTarget.value = text
    this.outputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    this.outputTarget.focus()
  }

  showLoading() {
    if (this.hasSpinnerTarget) {
      // 1. Unhide the span
      this.spinnerTarget.classList.remove("hide")
      // 2. Start the animation
      this.spinnerTarget.classList.add("animate-spin")
    }
  }

  hideLoading() {
    if (this.hasSpinnerTarget) {
      // 1. Stop the animation
      this.spinnerTarget.classList.remove("animate-spin")
      // 2. Hide the span
      this.spinnerTarget.classList.add("hide")
    }
  }
}