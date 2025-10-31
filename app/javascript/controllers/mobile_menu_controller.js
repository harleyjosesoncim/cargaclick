import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel", "button"]

  connect() {
    this.close()
    // fecha em cada navegação Turbo
    window.addEventListener("turbo:load", () => this.close(), { passive: true })
  }

  toggle() { this.isOpen() ? this.close() : this.open() }

  open() {
    this.overlayTarget.classList.remove("hidden")
    this.panelTarget.classList.remove("hidden")
    this.buttonTarget?.setAttribute("aria-expanded", "true")
    document.documentElement.classList.add("overflow-hidden") // trava scroll do fundo
  }

  close() {
    this.overlayTarget?.classList.add("hidden")
    this.panelTarget?.classList.add("hidden")
    this.buttonTarget?.setAttribute("aria-expanded", "false")
    document.documentElement.classList.remove("overflow-hidden")
  }

  isOpen() {
    return !this.panelTarget.classList.contains("hidden")
  }
}
