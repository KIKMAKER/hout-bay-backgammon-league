import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const loanId = this.element.dataset.bookLoanBannerLoanIdValue
    if (!loanId) return
    if (sessionStorage.getItem(`book_loan_banner_dismissed_${loanId}`)) {
      this.element.remove()
    }
  }

  dismiss() {
    const loanId = this.element.dataset.bookLoanBannerLoanIdValue
    if (loanId) {
      sessionStorage.setItem(`book_loan_banner_dismissed_${loanId}`, "1")
    }
    this.element.classList.remove("show")
    setTimeout(() => this.element.remove(), 150)
  }
}
