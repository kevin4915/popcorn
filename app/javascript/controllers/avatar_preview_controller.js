import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    if (!file.type.startsWith("image/")) return

    const reader = new FileReader()

    reader.onload = (event) => {
      this.imageTarget.src = event.target.result
    }

    reader.readAsDataURL(file)
  }
}
