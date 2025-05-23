import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-fields"
export default class extends Controller {
  static targets = ["fields", "template"];

  append() {
    this.fieldsTarget.insertAdjacentHTML("beforeend", this.#templateContent);
  }

  get #templateContent() {
    return this.templateTarget.innerHTML.replace(/__INDEX__/g, Date.now());
  }

  remove(event) {
    event.preventDefault()

    const fieldWrapper = event.target.closest(".nested-fields")
    if (!fieldWrapper) return;

    const destroyField = fieldWrapper.querySelector('input[name*="_destroy"]');
    if (destroyField) {
      destroyField.value = "1";
      fieldWrapper.style.display = "none";
    }
  }
}
