import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn", "icon"]
  static values  = { added: Boolean }

  toggle() {
    const movieId = this.btnTarget.dataset.movieId
    const method  = this.addedValue ? "DELETE" : "POST"
    const url     = this.addedValue
      ? `/movies/${movieId}/remove_from_list`
      : `/movies/${movieId}/add_to_list`

    fetch(url, {
      method,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      }
    }).then(response => {
      if (response.ok) {
        this.addedValue = !this.addedValue
        this.iconTarget.className = `fa-solid ${this.addedValue ? "fa-check" : "fa-heart"}`
        this.btnTarget.classList.remove("btn-added", "btn-add-list")
        this.btnTarget.classList.add(this.addedValue ? "btn-added" : "btn-add-list")
      }
    })
  }
}
