import MainView from "../main";
import select2Selector from "./../../form-helpers/select2-selector";

export default class View extends MainView {
  mount() {
    super.mount();

    let children_ul = null;
    let delete_taxon_id = null;

    $(".taxonomy").on("click", ".edit-taxon", function(e) {
      $("#edittaxon-modal").modal({ show: true });
      var name = $(this)
        .closest("table")
        .siblings(".taxon_name")
        .text();
      var id = $(this)
        .closest("li")
        .data("taxon_id");
      $(`#taxon-edit-loader`)
        .addClass(`loader`)
        .show();
      e.stopPropagation();
      fetch("/api/taxon/" + id)
        .then(function(response) {
          return response.json();
        })
        .then(function(json) {
          $(`#taxon-edit-body`)
            .empty()
            .append(json.html);
          $(`#taxon-edit-loader`)
            .removeClass(`loader`)
            .hide();
          $("#edit-taxon-danger").hide();
          select2Selector();
        });
    });

    $(".taxonomy").on("click", ".add-taxon", function(e) {
      $("#new-taxon-danger").hide();
      $("#taxon-modal").modal({ show: true });
      $(".modal-body select")
        .val("")
        .trigger("change");
      $(".modal-body input[type=text], input[type=file]").val("");
      var id = $(this)
        .closest("li")
        .data("taxon_id");
      let chidren_selector = `ul[data-parent_id="` + id + `"]`;
      children_ul = $(chidren_selector);
      $("#form-taxon-id").val(id);
      e.stopPropagation();
    });

    $(".taxonomy").on("click", ".delete-taxon", function(e) {
      e.stopPropagation();
      $(`#deletetaxon-modal`).modal({ show: true });
      $(`#taxon-delete-loader`)
        .addClass(`loader`)
        .show();
      $("#delete-taxon-danger").hide();
      let taxon_id = $(this)
        .closest("li")
        .data("taxon_id");
      delete_taxon_id = taxon_id;
      fetch("/api/taxon/" + taxon_id + "/aggregate")
        .then(function(response) {
          if (response.ok) return response.json();
          else {
            throw Error("Category request failed");
          }
        })
        .then(function(json) {
          $(`#taxon-delete-body`)
            .show()
            .empty()
            .append(json.html);
          $(`#taxon-delete-loader`)
            .removeClass(`loader`)
            .hide();
        })
        .catch(function(error_message) {
          $(`#taxon-delete-body`).hide();
          $(`#taxon-delete-loader`)
            .removeClass(`loader`)
            .hide();
          $("#delete-taxon-danger").html(error_message);
          $("#delete-taxon-danger").show();
        });
    });

    $("#taxon_delete").click(function() {
      fetch("/api/taxon/" + delete_taxon_id, {
        method: "DELETE"
      }).then(response => {
        $(`#deletetaxon-modal`).modal("hide");
      });
    });

    $(".taxonform").on("submit", function(event) {
      event.preventDefault();
      var tid = $("#form-taxon-id").val();
      var form_data = new FormData();
      var image_file = $(this).find('input[name="taxon[image]"]')[0].files[0];
      var name = $(this)
        .find('input[name="taxon[name]"]')
        .val();
      var themes = $("#taxons_taxons").val();
      var csrf = $(this)
        .find("input:hidden")
        .val();
      form_data.append("image", image_file);
      form_data.append("name", name);
      form_data.append("themes", themes);
      form_data.append("_csrf_token", csrf);
      form_data.append("id", tid);

      $("#new-taxon-danger").slideUp("fast");

      $.ajax({
        url: "/taxonomy",
        type: "POST",
        data: form_data,
        processData: false,
        contentType: false,
        success: function(result) {
          $("#taxon-modal").modal("hide");
          $(result.html)
            .hide()
            .appendTo(children_ul)
            .show("normal");
        },
        error: function(result) {
          let error_json = result.responseJSON;
          $("#new-taxon-danger").html(error_json.error.message);
          $("#new-taxon-danger").slideDown("slow");
        }
      });
    });

    $("#taxon-edit-body").on("submit", ".edittaxonform", function(event) {
      event.preventDefault();

      var form_data = new FormData();
      var name = $(this)
        .find("#editform-taxon-name")
        .val();
      var themes = $("#taxon-edit-body #taxons_taxons").val();
      var image_file = $(this).find('input[name="taxon[image]"]')[0].files[0];
      var id = $(this)
        .find("#editform-taxon-id")
        .val();

      form_data.append("taxon[taxon_id]", id);
      form_data.append("taxon[taxon]", name);
      form_data.append("taxon[image]", image_file);
      form_data.append("taxon[themes]", themes);

      $("#edit-taxon-danger").slideUp("fast");

      $.ajax({
        url: "/api/taxonomy/update",
        type: "PUT",
        data: form_data,
        processData: false,
        contentType: false,
        success: function(result) {
          $("#edittaxon-modal").modal("hide");
          let taxon_id = result.id;
          let i_selector = "li[data-taxon_id='" + taxon_id + "'] > span > i";
          $(i_selector).html(result.name);
          let span_selector = "li[data-taxon_id='" + taxon_id + "'] > span";
          let span = $(span_selector);
          span.css({ backgroundColor: "#00FA9A" });
          span.animate({ backgroundColor: "#fbfbfb" }, "slow", function() {
            span.removeAttr("style");
          });
        },
        error: function(result) {
          let error_json = result.responseJSON;
          $("#edit-taxon-danger").html(error_json.error.message);
          $("#edit-taxon-danger").slideDown("slow");
        }
      });
    });

    $(".tree li:has(ul)").addClass("parent_li");
    $(".taxonomy").on("click", "span", function(e) {
      var children = $(this)
        .parent("li.parent_li")
        .find(" > ul > li");
      if (children.is(":visible")) {
        children.hide("fast");
        $(this)
          .find(" > i")
          .addClass("icon-plus-sign")
          .removeClass("icon-minus-sign");
      } else {
        children.show("fast");
        $(this)
          .find(" > i")
          .addClass("icon-minus-sign")
          .removeClass("icon-plus-sign");
      }
      e.stopPropagation();
    });

    // handle taxon_id from query from URl
    let params = this.get_query_params();
    if (params["taxon_id"] != undefined) {
      var id = params["taxon_id"];
      $(`#taxon-edit-loader`)
        .addClass(`loader`)
        .show();
      fetch("/api/taxon/" + id)
        .then(function(response) {
          if (!response.ok) {
            $("#edittaxon-modal").modal("hide");
            throw Error("Api failed");
          }

          return response.json();
        })
        .then(function(json) {
          $("#edittaxon-modal").modal({ show: true });
          $(`#taxon-edit-body`)
            .empty()
            .append(json.html);
          $(`#taxon-edit-loader`)
            .removeClass(`loader`)
            .hide();
          select2Selector();
        })
        .catch(function(error) {
          // Show error message in the UI
        });
    }
  }

  get_query_params() {
    let pairs = window.location.search.slice(1).split("&");

    var result = {};
    pairs.forEach(function(pair) {
      pair = pair.split("=");
      result[pair[0]] = decodeURIComponent(pair[1] || "");
    });
    return result;
  }

  unmount() {
    super.unmount();
  }
}
