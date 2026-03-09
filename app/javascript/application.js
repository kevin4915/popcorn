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

document.addEventListener("turbo:load", () => {
  const avatar = document.getElementById("avatarDropdown");
  const menu = document.getElementById("dropdownMenu");

  if (avatar) {
    avatar.addEventListener("click", () => {
      menu.classList.toggle("active");
    });

    // Ferme le menu si on clique ailleurs
    document.addEventListener("click", (e) => {
      if (!avatar.contains(e.target)) {
        menu.classList.remove("active");
      }
    });
  }
});
