// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.dispatch_event = function() {
  const name = this.getAttribute("name")
  const event = new CustomEvent(name, { bubbles: true })
  window.dispatchEvent(event)
}