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
      // THE CHANGE: Set the default desktop height to 68dvh.
      this.outputTarget.style.height = '68dvh'
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

    if (this.isMobile()) {
      // --- MOBILE LOGIC (No changes) ---
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
        // THE CHANGE: The height no longer needs to be set here.
      } else {
        this.show(this.samplesTarget)
        this.hide(this.desktopInfoTarget)
        // THE CHANGE: The height no longer needs to be set here.
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