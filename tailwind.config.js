/** @type {import('tailwindcss').Config} */
module.exports = {
  // ============================================================
  // MODO ESCURO
  // ============================================================
  darkMode: 'class', // ativa dark mode via classe .dark no <html> ou <body>

  // ============================================================
  // PATHS → onde o Tailwind vai procurar classes
  // ============================================================
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/javascript/**/*.jsx',
    './app/javascript/**/*.ts',
    './app/javascript/**/*.tsx'
  ],

  // ============================================================
  // TEMA CUSTOMIZADO
  // ============================================================
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#4F46E5', // Roxo base
          dark: '#3730A3',
          light: '#818CF8'
        }
      }
    }
  },

  // ============================================================
  // PLUGINS
  // ============================================================
  plugins: [
    require('@tailwindcss/forms'),        // estilização de inputs/forms
    require('@tailwindcss/typography'),   // estilização de textos longos
    require('@tailwindcss/aspect-ratio')  // controle de proporções (ex: imagens/vídeos)
  ]
}

