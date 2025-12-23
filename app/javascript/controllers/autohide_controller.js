import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-hide the element after 5 seconds
    setTimeout(() => {
      this.hide()
    }, 5000)
  }

  hide() {
    // Use Bootstrap's alert dismiss functionality
    this.element.classList.remove('show')

    // Remove element from DOM after fade animation completes
    setTimeout(() => {
      this.element.remove()
    }, 150) // Bootstrap's fade transition is 150ms
  }
}
