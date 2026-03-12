import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "genreSelect", "durationBlock"]

  connect() {
    this.movieGenres = [
      "Action",
      "Animation",
      "Aventure",
      "Comédie",
      "Documentaire",
      "Drame",
      "Familial",
      "Fantastique",
      "Guerre",
      "Historique",
      "Horreur",
      "Musique",
      "Mystère",
      "Policier",
      "Romance",
      "Science Fiction",
      "Show télé",
      "Thriller",
      "Western"
    ]

    this.tvGenres = [
      "Action & Aventure",
      "Animation",
      "Comédie",
      "Policier",
      "Documentaire",
      "Drame",
      "Familial",
      "Enfants",
      "Mystère",
      "News",
      "Reality show",
      "Science Fiction & Fantasie",
      "Soap",
      "Show télé",
      "Guerre & Politique",
      "Western"
    ]

    this.updateForm()
  }

  updateForm() {
    const isSeries = this.toggleTarget.checked
    const genres = isSeries ? this.tvGenres : this.movieGenres

    this.genreSelectTarget.innerHTML = ""

    const blankOption = document.createElement("option")
    blankOption.value = ""
    blankOption.textContent = "Choisir un genre"
    this.genreSelectTarget.appendChild(blankOption)

    genres.forEach((genre) => {
      const option = document.createElement("option")
      option.value = genre
      option.textContent = genre
      this.genreSelectTarget.appendChild(option)
    })

    if (isSeries) {
      this.durationBlockTarget.style.display = "none"
      this.durationBlockTarget
        .querySelectorAll('input[type="radio"]')
        .forEach((input) => input.checked = false)
    } else {
      this.durationBlockTarget.style.display = "block"
    }
  }
}
