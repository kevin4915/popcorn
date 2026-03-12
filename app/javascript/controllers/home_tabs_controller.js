import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["tab", "filmsPanel", "seriesPanel", "forYouPanel"]

  connect() {
    this.showFilms()
  }

  showFilms() {
    this.filmsPanelTarget.style.display = "block"
    this.seriesPanelTarget.style.display = "none"
    this.forYouPanelTarget.style.display = "none"

    this.activateTab(0)
  }

  showSeries() {
    this.filmsPanelTarget.style.display = "none"
    this.seriesPanelTarget.style.display = "block"
    this.forYouPanelTarget.style.display = "none"

    this.activateTab(1)
  }

  showForYou() {
    this.filmsPanelTarget.style.display = "none"
    this.seriesPanelTarget.style.display = "none"
    this.forYouPanelTarget.style.display = "block"

    this.activateTab(2)
  }

  activateTab(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("active", i === index)
    })
  }

}
