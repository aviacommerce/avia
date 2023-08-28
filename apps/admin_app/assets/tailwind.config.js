// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require('tailwindcss/plugin');
const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
    "../deps/petal_components/**/*.*ex",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        secondary: colors.pink,
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({ addVariant }) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({ addVariant }) => addVariant('phx-click-loading', [
      '&.phx-click-loading',
      '.phx-click-loading &',
    ])),
    plugin(({ addVariant }) => addVariant('phx-submit-loading', [
      '&.phx-submit-loading',
      '.phx-submit-loading &',
    ])),
    plugin(({ addVariant }) => addVariant('phx-change-loading', [
      '&.phx-change-loading',
      '.phx-change-loading &',
    ])),
  ],
};
