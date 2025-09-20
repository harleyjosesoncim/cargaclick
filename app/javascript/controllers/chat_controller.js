import { Controller } from "@hotwired/stimulus"

// Conecta Turbo Streams + scroll automático
export default class extends Controller {
  static values = { chatId: Number }

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    const messages = this.element
    if (messages) {
      messages.scrollTop = messages.scrollHeight
    }
  }

  // Sempre que Turbo Stream insere algo novo, rola pro fim
  messagesTargetConnected() {
    this.scrollToBottom()
  }
}
