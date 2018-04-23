exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //   "js/app.js": /^js/,
      //   "js/vendor.js": /^(?!js)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "assets/node_modules/jquery/dist/jquery.min.js",
      //     "assets/node_modules/popover/popover.js",
      //     "assets/node_modules/bootstrap/dist/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["priv/static/css/app.scss"]
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "css", "js", "vendor"],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    sass: {
      options: {
        includePaths: ["node_modules/bootstrap/scss", "node_modules/font-awesome/scss"], // tell sass-brunch where to look for files to @import
        precision: 8 // minimum precision required by bootstrap
      }
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true,
    globals: {
      $: 'jquery',
      jQuery: 'jquery',
      Popper: 'popper.js',
      Tether: 'tether',
      bootstrap: 'bootstrap'
    }
  }
};
