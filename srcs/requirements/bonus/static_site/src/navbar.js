// Navbar

document.addEventListener("DOMContentLoaded", function () {
  "use strict";

  document.addEventListener('DOMContentLoaded', () => {
    const navItems = document.querySelectorAll('.nav__list-item');
    const currentPage = window.location.pathname.split('/').pop().replace('.html', '');

    navItems.forEach((item) => {
      const navValue = item.getAttribute('data-nav');
      if (navValue === currentPage || (navValue === 'home' && currentPage === '')) {
        item.classList.add('active-nav');
      } else {
        item.classList.remove('active-nav');
      }
    });
  });


  const navbar = document.querySelector('.cd-header');
  const nav = document.querySelector('.nav');
  const cursor = document.getElementById("cursor");
  const cursor2 = document.getElementById("cursor2");
  const cursor3 = document.getElementById("cursor3");

  function toggleClass(element, stringClass) {
    element.classList.toggle(stringClass);
  }

  if (cursor && cursor2 && cursor3) {
    // Page cursors
    document.body.addEventListener("mousemove", function (event) {
      cursor.style.left = event.clientX + "px";
      cursor.style.top = event.clientY + "px";
      cursor2.style.left = event.clientX + "px";
      cursor2.style.top = event.clientY + "px";
      cursor3.style.left = event.clientX + "px";
      cursor3.style.top = event.clientY + "px";

      const isCursorInNavbar = navbar.contains(event.target) || nav.contains(event.target);
      if (isCursorInNavbar) {
        cursor.style.display = 'block';
        cursor2.style.display = 'block';
        cursor3.style.display = 'block';
      } else {
        cursor.style.display = 'none';
        cursor2.style.display = 'none';
        cursor3.style.display = 'none';
      }
    });

    function addHoverClass() {
      cursor2.classList.add("hover");
      cursor3.classList.add("hover");
    }

    function removeHoverClass() {
      cursor2.classList.remove("hover");
      cursor3.classList.remove("hover");
    }

    removeHoverClass();

    const hoverTargets = document.querySelectorAll(".hover-target");
    hoverTargets.forEach((target) => {
      target.addEventListener("mouseover", addHoverClass);
      target.addEventListener("mouseout", removeHoverClass);
    });
  }

  // Navigation
  const app = (() => {
    let body, menu, menuItems;

    function init() {
      body = document.querySelector("body");
      menu = document.querySelector(".menu-icon");
      menuItems = document.querySelectorAll(".nav__list-item");
      applyListeners();
    }

    function applyListeners() {
      menu.addEventListener("click", () => {
        toggleClass(body, "nav-active");
      });
    }

    init();
  })();
});
