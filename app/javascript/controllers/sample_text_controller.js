import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "output", "samples", "desktopInfo", "mobileInfo", "resetButton" ]

  connect() {
    this.originalPlaceholder = this.outputTarget.placeholder
    
    // On page load, always show the sample texts.
    this.show(this.samplesTarget)

    // Set the initial height for the textarea based on screen size.
    if (this.isMobile()) {
      this.outputTarget.style.height = '40dvh'
    } else {
      this.outputTarget.style.height = '55dvh'
    }
  }

  // --- ACTIONS ---

  insert(event) {
    const textToInsert = event.params.text
    this.outputTarget.value = textToInsert
    this.outputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  handleInput() {
    const hasText = this.outputTarget.value.length > 0

    // --- FIX: Iterate over ALL resetButton targets ---
    // This ensures both the mobile and desktop buttons are updated correctly.
    this.resetButtonTargets.forEach(button => {
      button.hidden = !hasText
    })

    if (this.isMobile()) {
      // --- MOBILE LOGIC ---
      if (hasText) {
        this.hide(this.samplesTarget)
        this.outputTarget.style.height = '70dvh'
      } else {
        this.show(this.samplesTarget)
        this.outputTarget.style.height = '40dvh'
      }
    } else {
      // --- DESKTOP LOGIC ---
      if (hasText) {
        this.hide(this.samplesTarget)
        this.show(this.desktopInfoTarget)
        this.outputTarget.style.height = '75dvh'
      } else {
        this.show(this.samplesTarget)
        this.hide(this.desktopInfoTarget)
        this.outputTarget.style.height = '55dvh'
      }
    }
  }
  
  resetForm() {
    const form = document.getElementById(this.outputTarget.getAttribute('form'))
    if (form) form.reset()
    
    this.outputTarget.value = ""
    this.outputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  // --- HOVER LOGIC ---
  showPlaceholder(event) {
    this.outputTarget.placeholder = event.params.text
  }

  hidePlaceholder() {
    this.outputTarget.placeholder = this.originalPlaceholder
  }
  
  // --- HELPERS ---

  isMobile() {
    return this.mobileInfoTarget.offsetParent !== null
  }

  // --- ANIMATION HELPERS ---
  show(element) {
    if (!element || element.hidden === false) return;
    element.hidden = false
    element.style.animation = `var(--animate-fade-in) forwards, var(--animate-slide-in-up) forwards`
  }

  hide(element) {
    if (!element || element.hidden === true) return;
    element.style.animation = `var(--animate-fade-out) forwards, var(--animate-slide-out-down) forwards`
    setTimeout(() => {
      element.hidden = true
    }, 500)
  }
}