import { Controller } from "@hotwired/stimulus"

const AU_RATE   = 0.0175
const INTL_RATE = 0.0525 // 0.0175 + 0.035
const FIXED_FEE = 0.30

export default class extends Controller {
  static targets = ["paymentElement", "errors", "submit", "surchargeSection", "surchargeAmount", "surchargeField", "totalAmount", "totalAmountField", "paymentMethodId"]
  static values  = {
    publishableKey: String,
    clientSecret:   String,
    lineItemsTotal: Number
  }

  async connect() {
    this.stripe = Stripe(this.publishableKeyValue)

    const elements = this.stripe.elements({ clientSecret: this.clientSecretValue, paymentMethodCreation: "manual" })
    this.elements = elements

    const paymentElement = elements.create("payment")
    paymentElement.mount(this.paymentElementTarget)

    paymentElement.on("change", (event) => {
      if (event.complete) this.#calculateSurcharge()
    })
  }

  submit(event) {
    this.setLoading(true)
  }

  setLoading(loading) {
    this.submitTarget.disabled = loading
    if (loading) {
      this.submitTarget.dataset.originalText = this.submitTarget.value
      this.submitTarget.value = "Processing…"
    } else {
      this.submitTarget.value = this.submitTarget.dataset.originalText
    }
  }

  async #calculateSurcharge() {
    await this.elements.submit()

    const { paymentMethod, error } = await this.stripe.createPaymentMethod({ elements: this.elements, params: {} })
    if (error || !paymentMethod?.card) return

    this.paymentMethodIdTarget.value = paymentMethod.id

    const country        = paymentMethod.card.country
    const subtotal       = this.lineItemsTotalValue
    const rate           = country === "AU" ? AU_RATE : INTL_RATE
    const surcharge      = parseFloat((subtotal * rate + FIXED_FEE).toFixed(2))
    const total          = parseFloat((subtotal + surcharge).toFixed(2))

    this.surchargeAmountTarget.textContent = this.#formatCurrency(surcharge)
    this.surchargeFieldTarget.value        = surcharge

    this.totalAmountTarget.textContent = this.#formatCurrency(total)
    this.totalAmountFieldTarget.value  = total

    this.surchargeSectionTarget.classList.remove("hidden")
    this.submitTarget.value = `Pay ${this.#formatCurrency(total)}`
  }

  #formatCurrency(amount) {
    return `A$${amount.toFixed(2)}`
  }
}
