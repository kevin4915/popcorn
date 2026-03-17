import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "endState"]

  handleSwipe(event) {
    event.preventDefault()

    const button = event.currentTarget
    const decision = button.dataset.decision
    const card = button.closest(".swipe-card")
    const movieId = card.dataset.movieId

    card.querySelectorAll("button").forEach((btn) => {
      btn.disabled = true
    })

    fetch(`/movies/${movieId}/swipe`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ decision: decision })
    }).catch((error) => {
      console.error("Erreur pendant le swipe :", error)
    })

    if (decision === "like") {
      this.cardTargets.forEach((otherCard) => {
        if (otherCard !== card) {
          otherCard.style.visibility = "hidden"
        }
      })

      card.style.zIndex = "999"
      card.style.transition = "transform 0.25s ease, opacity 0.25s ease"
      card.style.transform = "scale(1.03)"
      card.style.opacity = "0.98"

      setTimeout(() => {
        window.location.href = `/movies/${movieId}?from=home`
      }, 250)

      return
    }

    card.classList.remove("swiped-left", "swiped-right")
    card.classList.add("swiped-left")
    card.style.transition = "transform 0.4s ease-out"
    card.style.transform = "translateX(-100vw) rotate(-20deg)"

    setTimeout(() => {
      card.remove()

      const remainingCards = this.cardTargets.filter((el) => el.isConnected)
      if (remainingCards.length === 0) {
        this.endStateTarget.style.display = "flex"
      }
    }, 400)
  }
}
