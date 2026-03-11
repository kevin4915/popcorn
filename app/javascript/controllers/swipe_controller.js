import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "endState"]

  handleSwipe(event) {
    const button = event.currentTarget
    const decision = button.dataset.decision

    const card = button.closest('.swipe-card')
    const movieId = card.dataset.movieId

    card.classList.remove('swiped-left', 'swiped-right')
    card.classList.add(decision === 'like' ? 'swiped-right' : 'swiped-left')

    fetch(`/movies/${movieId}/swipe`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ decision: decision })
    })

    card.style.transition = "transform 0.4s ease-out"
    card.style.transform = decision === "like" ? "translateX(100vw) rotate(20deg)" : "translateX(-100vw) rotate(-20deg)"

    setTimeout(() => {
      card.remove()

      if (decision === "like") {
        window.location.href = `/movies/${movieId}`
      } else if (this.cardTargets.length === 0) {
        this.endStateTarget.style.display = "flex"
      }
    }, 400)
  }
}
