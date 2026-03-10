import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  handleSwipe(event) {
    const button = event.currentTarget
    const decision = button.dataset.decision


    const card = button.closest('.movie-card')
    const movieId = card.dataset.movieId

    card.classList.remove('swiped-left', 'swiped-right')
    card.classList.add(decision === 'like' ? 'swiped-right' : 'swiped-left')

    fetch(`/movies/${movieId}/swipe`, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
      body: JSON.stringify({ decision: decision })
    })

    card.style.transition = "transform 0.4s ease-out"
    card.style.transform = decision === "like" ? "translateX(100vw) rotate(20deg)" : "translateX(-100vw) rotate(-20deg)"

    setTimeout(() => card.remove(), 400)
  }
}
