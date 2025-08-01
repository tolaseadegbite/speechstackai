import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "output", "samples", "desktopInfo", "mobileInfo" ]

  connect() {
    this.originalPlaceholder = this.outputTarget.placeholder
    
    // On page load, always show the sample texts.
    this.show(this.samplesTarget)

    // Set the initial height for the textarea based on screen size.
    if (this.isMobile()) {
      this.outputTarget.style.height = '40dvh'
    } else {
      this.outputTarget.style.height = '55dvh' // Initial desktop height
    }
  }

  // --- ACTIONS ---

  // Called when a sample button is clicked.
  insert(event) {
    const textToInsert = event.params.text
    this.outputTarget.value = textToInsert
    this.outputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    // The 'input' event will automatically trigger handleInput()
  }

  // Called when the user types or text is inserted.
  handleInput() {
    const hasText = this.outputTarget.value.length > 0

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
        // Hide samples, show the desktop info bar, and expand textarea.
        this.hide(this.samplesTarget)
        this.show(this.desktopInfoTarget)
        this.outputTarget.style.height = '75dvh'
      } else {
        // Show samples, hide the desktop info bar, and shrink textarea.
        this.show(this.samplesTarget)
        this.hide(this.desktopInfoTarget)
        this.outputTarget.style.height = '55dvh'
      }
    }
  }

  // --- HOVER LOGIC ---
  showPlaceholder(event) {
    this.outputTarget.placeholder = event.params.text
  }

  hidePlaceholder() {
    this.outputTarget.placeholder = this.originalPlaceholder
  }
  
  // --- HELPERS ---

  // Checks if we are in the mobile layout by seeing if the mobileInfo target is visible.
  isMobile() {
    // `offsetParent` is null if an element or its parents have `display: none`.
    return this.mobileInfoTarget.offsetParent !== null
  }

  // --- ANIMATION HELPERS ---
  show(element) {
    // Guard clause: do nothing if element doesn't exist or is already visible.
    if (!element || element.hidden === false) return;
    
    element.hidden = false
    element.style.animation = `var(--animate-fade-in) forwards, var(--animate-slide-in-up) forwards`
  }

  hide(element) {
    // Guard clause: do nothing if element doesn't exist or is already hidden.
    if (!element || element.hidden === true) return;
    
    element.style.animation = `var(--animate-fade-out) forwards, var(--animate-slide-out-down) forwards`
    setTimeout(() => {
      element.hidden = true
    }, 500)
  }
}