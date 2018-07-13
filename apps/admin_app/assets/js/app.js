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
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import "bootstrap";
import select2Selector from './form-helpers/select2-selector';

$(document).ready(() => {
  select2Selector();
  setup_product();
})

const elmDiv = document.getElementById("elm-main");
Elm.Main.embed(elmDiv);

function setup_product(){
  // This handle the variation theme selection
  $('#product_theme_id').on('change', function (e) {
    $('#theme_change_modal').modal(`show`);
  })

  $("#theme_change_confirm").click(function(e){
      var optionSelected = $("option:selected");
      var valueSelected = optionSelected.val();
      const product_id = $(this)
        .parents()
        .find('#product_id');
      const new_variant = $(this)
        .parents()
        .find('#new_variant');
      var link = "/products/" + product_id.val() + "/variant/new?theme_id=" + valueSelected
      new_variant.attr("href", link)

      get_variation_options(valueSelected, product_id.val())
  })

  var product_id = $("#product_id").val();
  var theme_id = $("#product_theme_id").val();
  get_variation_options(theme_id, product_id)
}

function get_variation_options(theme_id, product_id)
{
  fetch('http://localhost:4000/api/option_types?theme_id=' + theme_id + "&product_id=" + product_id)
  .then(function(response) {
    return response.json();
  })
  .then(function(myJson) {
    $('#variation_options')
    .empty()
    .append(myJson.html)
  });
  $('#theme_change_modal').modal('hide');
}
