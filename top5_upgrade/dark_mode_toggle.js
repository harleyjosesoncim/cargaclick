const toggle = document.getElementById("dark-toggle");
const html = document.documentElement;
if (localStorage.theme === 'dark') html.classList.add("dark");

toggle.addEventListener("click", () => {
  html.classList.toggle("dark");
  localStorage.theme = html.classList.contains("dark") ? "dark" : "light";
});
