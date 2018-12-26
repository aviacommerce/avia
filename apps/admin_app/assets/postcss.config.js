// The list of browsers that we support
const supportedBrowsers = ["last 2 versions"];

module.exports = {
  plugins: [
    require("autoprefixer")({ browsers: supportedBrowsers }),
    require("cssnano")()
  ]
};
