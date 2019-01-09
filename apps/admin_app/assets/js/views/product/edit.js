import MainView from "../main";
import { addEventToProductFormButtons } from "./publish_helper";

export default class View extends MainView {
  mount() {
    super.mount();

    // Specific logic here
    console.log("ProductEditView mounted");
    imageOnEnter();
    disableDeletionforSelected();
    setDefaultImage();
    handleImageSelect();
    deleteImage();
    setupProduct();
    setVariantState();
    switchVariantState();
    addEventToProductFormButtons();

    if ($("#inventory_tab").length) {
      setSelectedInventoryTracking();
      setupProductTracking();
      handleInventoryTrackingToggle();
    }

    if ($("#options_tab").length) {
      handleStockForProductTracking();
      handleStockForVariantTracking();
    }
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log("ProductEditView unmounted");
  }
}

var selDiv;
var storedFile = [];

export function handleStockForVariantTracking() {
  $(":button[name=variant_stock_add]").click(function() {
    $("#variant_stock_error_msg").slideUp("fast");

    let productId = $(this).attr("data-prdouct-id");
    $("#variant_tracking #stock_product_id").val(productId);

    let stockLocationId = $("#variant_tracking #stock_stock_location_id").val();
    getStockForVariantLevel(productId, stockLocationId);

    $("#variant_stock_modal").modal(`show`);
  });

  $("#variant_tracking #stock_stock_location_id").on("change", function() {
    let stockLocationId = this.value;
    let productId = $("#variant_tracking #stock_product_id").val();

    getStockForVariantLevel(productId, stockLocationId);
  });

  $("#variant_stock_modal #variant_stock_confirm").click(function() {
    $("#variant_stock_error_msg").slideUp("fast");

    let productId = $("#variant_tracking #stock_product_id").val();
    let stockLocationId = $("#variant_tracking #stock_stock_location_id").val();
    let stockLevel = $("#variant_tracking #stock_count_on_hand").val();
    let lowStockLevel = $(
      "#variant_tracking #stock_inventory_warning_level"
    ).val();

    const data = {
      stock: {
        product_id: productId,
        stock_location_id: stockLocationId,
        count_on_hand: stockLevel,
        inventory_warning_level: lowStockLevel
      }
    };

    $.ajax({
      url: `/api/stock_update`,
      type: "POST",
      data: data,
      success: function(json) {
        $("#variant_stock_modal").modal(`hide`);
        window.location.reload();
      },
      error: function(json) {
        $("#variant_stock_error_msg").slideDown("slow");
      }
    });
  });
}

export function getStockForVariantLevel(productId, stockLocationId) {
  $.ajax({
    url: `/api/stock`,
    type: "POST",
    data: { product_id: productId, stock_location_id: stockLocationId },
    success: function(json) {
      let $stockLevel = $("#variant_tracking #stock_count_on_hand");
      let $lowStockLevel = $(
        "#variant_tracking #stock_inventory_warning_level"
      );

      let stockLevel = 0;
      let lowStockLevel = 0;

      if (json.data.length > 0) {
        stockLevel = json.data[0].count_on_hand;
        lowStockLevel = json.data[0].inventory_warning_level;
      }

      $stockLevel.val(stockLevel);
      $lowStockLevel.val(lowStockLevel);
    }
  });
}

export function handleStockForProductTracking() {
  let stockLocationId = $("#product_tracking #stock_stock_location_id").val();
  let productId = $("#product_tracking #stock_product_id").val();

  if (stockLocationId && productId)
    getStockForProductLevel(productId, stockLocationId);

  $("#product_tracking #stock_stock_location_id").on("change", function() {
    let stockLocationId = this.value;
    let productId = $("#product_tracking #stock_product_id").val();

    getStockForProductLevel(productId, stockLocationId);
  });
}

export function getStockForProductLevel(productId, stockLocationId) {
  $.ajax({
    url: `/api/stock`,
    type: "POST",
    data: { product_id: productId, stock_location_id: stockLocationId },
    success: function(json) {
      let $stockLevel = $("#product_tracking #stock_count_on_hand");
      let $lowStockLevel = $(
        "#product_tracking #stock_inventory_warning_level"
      );

      let stockLevel = 0;
      let lowStockLevel = 0;

      if (json.data.length > 0) {
        stockLevel = json.data[0].count_on_hand;
        lowStockLevel = json.data[0].inventory_warning_level;
      }

      $stockLevel.val(stockLevel);
      $lowStockLevel.val(lowStockLevel);
    }
  });
}

export function handleInventoryTrackingToggle() {
  const inventory_tracking = $(
    'input[type=radio][name="product[inventory_tracking]"]:checked'
  ).val();

  inventory_tracking == "product"
    ? $("#product_tracking").slideDown("fast")
    : $("#product_tracking").slideUp("fast");

  $("input[type=radio][name='product[inventory_tracking]']").on(
    "change",
    function() {
      this.value == "product"
        ? $("#product_tracking").slideDown("fast")
        : $("#product_tracking").slideUp("fast");
    }
  );
}

export function setupProductTracking() {
  $("#product_tracking input[name=current_stock]").on("blur", function() {
    handle_stock(this);
  });
  $("#product_tracking input[name=stock_low]").on("blur", function() {
    handle_stock(this);
  });
}

export function handle_stock(stock_edit_element) {
  let $tr = $(stock_edit_element).closest("tr");
  let stock_location_id = $tr.attr("data-stock-location");
  let product_id = $tr.attr("data-product");

  let current_stock = $tr.find("input[name=current_stock]").val() || "0";
  let low_stock = $tr.find("input[name=stock_low]").val() || "0";

  const data = {
    stock_location_id: stock_location_id,
    current_stock: current_stock,
    low_stock: low_stock,
    product_id: product_id
  };

  fetch("/api/stock", {
    method: "POST",
    body: JSON.stringify(data),
    headers: {
      "Content-Type": "application/json"
    }
  }).then(res => {});
}

export function setSelectedInventoryTracking() {
  let inventory_tracking = $("#inventory_tracking").attr("data-selected");
  $(
    "#inventory_tracking input[type=radio][value=" + inventory_tracking + "]"
  ).attr("checked", true);
}

export function imageOnEnter() {
  $(document).delegate("#product-images", "change", function(event) {
    event.preventDefault();
    handleSubmitImage();
  });
}

export function setVariantState() {
  $(".product_variants").each(function() {
    var state = $(this)
      .find(".variant_state")
      .text();
    $(this)
      .find(`.switch-input[id=${state}]`)
      .closest("label")
      .addClass("active");
  });
}

export function switchVariantState() {
  $(document).on("change", ".switch-input", function(event) {
    var id = $(this)
      .closest(".variant_activate")
      .find(".variant_id")
      .val();
    var target_element = $(this);
    var state = $(this).prop("id");
    var data = { state: state };
    $.ajax({
      url: `/variant_state/${id}`,
      type: "PATCH",
      data: data,
      success: function(json) {
        target_element
          .closest(".product_variants")
          .find(".variant_state")
          .text(state);
      }
    });
  });
}

export function disableDeletionforSelected() {
  $(".imgcol input:checked")
    .parent()
    .find(".product-delete")
    .hide();
  $(".imgcol input:checked")
    .parent()
    .find(".product-info")
    .css("visibility", "visible");
}

export function setDefaultImage() {
  $(document).delegate('input[type="checkbox"]', "click", function(event) {
    $(this)
      .parent()
      .find(".product-delete")
      .hide();
    $(this)
      .parent()
      .find(".product-info")
      .css("visibility", "visible");
    $(this)
      .parent()
      .siblings()
      .find(".product-info")
      .css("visibility", "hidden");
    $(this)
      .parent()
      .siblings()
      .find(".product-delete")
      .show();
    $(this)
      .parent()
      .siblings()
      .find(":checkbox")
      .prop("checked", false);
    var default_image = $(this).val();
    var product_id = $("#product-id").val();
    var data = { product_id: product_id, default_image: default_image };
    var CSRF_TOKEN = $("meta[name='csrf-token']").attr("content");

    $.ajax({
      url: `/set-default-image/${product_id}`,
      type: "POST",
      cache: false,
      data: data,
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
      }
    });
  });
}

function handleSubmitImage() {
  var product_id = $("#product-id").val();
  var form_data = new FormData();
  var image_files = $("#product-image").find(
    "#product-images.file-upload__input"
  )[0].files;
  $.each(image_files, function(i, file) {
    form_data.append("product_images[images][]", file);
  });
  var csrf = $("meta[name='csrf-token']").attr("content");
  form_data.append("product_id", product_id);
  form_data.append("_csrf_token", csrf);
  $("#loadingmessage").addClass("loader");
  $.ajax({
    url: `/product-images/${product_id}`,
    type: "POST",
    data: form_data,
    processData: false,
    contentType: false,
    success: function(json) {
      $(`.file-upload`)
        .parent()
        .prepend(json.images);
      $(`#show-upload-response`)
        .empty()
        .append(json.html);
      $("#img-selected-container").empty();
      $("#loadingmessage").removeClass("loader");
    },
    error: function(json) {
      $(`#show-upload-response`)
        .empty()
        .append(json.responseJSON.html);
    }
  });
}

export function handleImageSelect() {
  document
    .querySelector("#product-images")
    .addEventListener("change", selectedFile, false);
  selDiv = $("#img-selected-container");
}

function selectedFile(e) {
  if (!e.target.files || !window.FileReader) return;

  selDiv.empty();
  var files = e.target.files;
  let filesArr = Array.prototype.slice.call(files);

  filesArr.forEach(function(f) {
    if (!f.type.match("image.*")) {
      return;
    }
    storedFile.push(f);
    var reader = new FileReader();
    reader.onload = function(e) {
      var html =
        '<div class="col-3 p-1 mb-2"><div class="media"><img class="align-self-start mr-3" src="' +
        e.target.result +
        '" alt="Generic placeholder image" /> </div></div>';
      selDiv.append(html);
    };
    reader.readAsDataURL(f);
  });
}

export function deleteImage() {
  $(document).delegate(".product-delete", "click", function() {
    let product_id = $("#product-id").val();
    let image_id = $(this)
      .find("input")
      .val();
    delete_product_image(product_id, image_id, this);
  });
}

function delete_product_image(product_id, image_id, reference) {
  var CSRF_TOKEN = $("meta[name='csrf-token']").attr("content");

  $.ajax({
    url:
      "/product-images" +
      "?" +
      $.param({
        product_id: product_id,
        image_id: image_id
      }),
    type: "DELETE",
    beforeSend: function(xhr) {
      xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    },
    success: function(data) {
      deleteSuccess(data, reference);
    },
    error: deleteError()
  });
}

function deleteSuccess(data, reference) {
  console.log("deleted data", data);
  $(reference)
    .closest(".img-wrap")
    .remove();
}

function deleteError(data) {
  console.log("errror data", data);
}

function setupProduct() {
  let previousOptionValue = "";

  // This handle the variation theme selection
  $("#product_theme_id").on("change", function(e) {
    var product_variants = document.getElementsByClassName(
      "product_has_variants"
    );

    if (product_variants.length != 0) {
      $("#theme_change_modal").modal(`show`);
    } else {
      create_update_variation_theme();
    }
  });

  $("#theme_change_confirm").click(function(e) {
    create_update_variation_theme();
  });

  $(".option-value").blur(function(evt) {
    var td = $(evt.target);
    let option_value_id = td.data("option_value_id");
    let value = td[0].innerText;
    if (value !== "") update_option_value(option_value_id, value);
    else {
      td.text(previousOptionValue);
    }
  });

  $(".option-value").focusin(function(evt) {
    var td = $(evt.target);
    previousOptionValue = td[0].innerText;
  });

  var product_id = $("#product_id").val();
  var theme_id = $("#product_theme_id").val();
  if (theme_id !== undefined && !(theme_id == ""))
    get_variation_options(theme_id, product_id);
}

function update_option_value(id, value) {
  $.ajax({
    type: "POST",
    url: "/api/product_option_values/" + id,
    crossDomain: true,
    data: { value: value },
    success: function(response) {}
  });
}

function get_variation_options(theme_id, product_id) {
  fetch("/api/option_types?theme_id=" + theme_id + "&product_id=" + product_id)
    .then(function(response) {
      return response.json();
    })
    .then(function(myJson) {
      $("#variation_options")
        .empty()
        .append(myJson.html);
    });
  $("#theme_change_modal").modal("hide");
}

function create_update_variation_theme() {
  var optionSelected = $("#product_theme_id");
  var valueSelected = optionSelected.val();

  const product_id = optionSelected.parents().find("#product_id");

  const new_variant = optionSelected.parents().find("#new_variant");

  var link =
    "/products/" + product_id.val() + "/variant/new?theme_id=" + valueSelected;
  new_variant.attr("href", link);

  get_variation_options(valueSelected, product_id.val());
}
