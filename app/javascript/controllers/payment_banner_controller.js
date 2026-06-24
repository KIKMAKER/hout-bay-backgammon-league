import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const roundId = this.element.dataset.paymentBannerRoundIdValue
    if (!roundId) return
    if (localStorage.getItem(`payment_banner_dismissed_round_${roundId}`)) {
      this.element.remove()
    }
  }

  dismiss() {
    const roundId = this.element.dataset.paymentBannerRoundIdValue
    if (roundId) {
      localStorage.setItem(`payment_banner_dismissed_round_${roundId}`, "1")
    }
    this.element.classList.remove("show")
    setTimeout(() => this.element.remove(), 150)
  }
}
