import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const stripe = Stripe(this.element.getAttribute('data-stripe-publishable-key'));
    const returnUrl = this.element.getAttribute('data-return-url');
    let elements;
    initialize(this.element.getAttribute('data-stripe-client-secret'));
    checkStatus();
    this.element.addEventListener("submit", handleSubmit);

    async function initialize(client_secret) {
      elements = stripe.elements({ clientSecret: client_secret });
      const paymentElement = elements.create("payment");
      paymentElement.mount("#payment-element");
    }

    async function handleSubmit(e) {
      e.preventDefault();
      setLoading(true);
      const { error } = await stripe.confirmPayment({
        elements,
        confirmParams: {
          return_url: returnUrl
        },
      });

      if (error.type === "card_error" || error.type === "validation_error") {
        showMessage(error.message);
      } else {
        showMessage("An unexpected error occurred.");
      }

      setLoading(false);
    }

    async function checkStatus() {
      const clientSecret = new URLSearchParams(window.location.search).get("payment_intent_client_secret");

      if (!clientSecret) {
        return;
      }

      const { paymentIntent } = await stripe.retrievePaymentIntent(clientSecret);

      switch (paymentIntent.status) {
        case "succeeded":
          showMessage("Payment succeeded!");
          break;

        case "processing":
          showMessage("Your payment is processing.");
          break;

        case "requires_payment_method":
          showMessage("Your payment was not successful, please try again.");
          break;

        default:
          showMessage("Something went wrong.");
          break;
      }
    }

    function showMessage(messageText) {
      const messageContainer = document.querySelector("#payment-message");

      messageContainer.classList.remove("hidden");
      messageContainer.classList.add("alert");
      messageContainer.classList.add("alert-danger");
      messageContainer.textContent = messageText;
    }

    function setLoading(isLoading) {
      if (isLoading) {
        document.querySelector("#submit").disabled = true;
        document.querySelector("#spinner").classList.remove("hidden");
        document.querySelector("#button-text").classList.add("hidden");
      } else {
        document.querySelector("#submit").disabled = false;
        document.querySelector("#spinner").classList.add("hidden");
        document.querySelector("#button-text").classList.remove("hidden");
      }
    }
  }
}
