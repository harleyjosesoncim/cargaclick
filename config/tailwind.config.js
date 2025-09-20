// config/tailwind.config.js
module.exports = {
  content: [
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    "./app/components/**/*.{rb,erb,haml,html,slim}",
  ],
  safelist: [
    // Botões
    "btn",
    "btn-blue",
    "btn-green",
    "btn-yellow",
    "btn-red",
    "btn-purple",
    "btn-indigo",

    // Cards
    "card",
    "card-title",

    // Formulários
    "form-input",

    // Utilitários comuns
    "text-center",
    "text-lg",
    "text-xl",
    "text-2xl",
    "text-3xl",
    "text-4xl",
    "font-bold",
    "font-semibold",
    "rounded-lg",
    "rounded-2xl",
    "shadow-lg",
    "shadow-2xl",
    "transition",
    "hover:scale-105",
    "hover:shadow-xl",
    "hover:shadow-2xl",
    "dark:bg-gray-800",
    "dark:text-gray-200",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
  ],
};
