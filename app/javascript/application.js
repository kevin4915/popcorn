// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".carousel-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const id = btn.dataset.carousel;
      const direction = parseInt(btn.dataset.direction);
      const carousel = document.getElementById(`carousel-${id}`);
      carousel.scrollBy({ left: direction * 240, behavior: 'smooth' });
    });
  });
});

const closeUserMenus = () => {
  document.querySelectorAll(".dropdown-menu-custom").forEach((menu) => {
    menu.classList.remove("active")
  })

  document.querySelectorAll(".avatar-dropdown").forEach((dropdown) => {
    dropdown.classList.remove("active")
  })
}

document.addEventListener("turbo:before-cache", closeUserMenus)
document.addEventListener("turbo:load", closeUserMenus)
