// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import "bootstrap";
import 'flowbite';
import select2Selector from "./form-helpers/select2-selector";
import loadView from "./views/loader";

import React from "react";
import ReactDOM from "react-dom";
import App from "./components/App";

const reactAppContainer = document.getElementById("react-app");
if (reactAppContainer) {
  ReactDOM.render(<App />, reactAppContainer);
}

function handleDOMContentLoaded() {
  // Get the current view name
  let viewName = document.getElementsByTagName("body")[0].dataset.jsViewName;
  
  if (viewName === 'ViewTemplateView' || viewName === 'StaticTemplateView') {
    viewName = document.querySelectorAll('[data-phx-view]')[0].dataset.phxView;
    viewName = viewName
      .replace('Elixir.AdminAppWeb.', '')
      .replace('.', '')
      .concat('View');
  }

  // Load view class and mount it
  const ViewClass = loadView(viewName);
  const view = new ViewClass();
  view.mount();

  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

window.addEventListener("DOMContentLoaded", handleDOMContentLoaded, false);
window.addEventListener("unload", handleDocumentUnload, false);

$(document).ready(() => {
  select2Selector();
});
