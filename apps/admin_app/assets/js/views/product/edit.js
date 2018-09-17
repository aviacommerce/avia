import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    // Specific logic here
    console.log('ProductEditView mounted');
    handleImageSelect();
    deleteImage();
    setup_product();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('ProductEditView unmounted');
  }
}

var selDiv
var storedFile = []

export function handleImageSelect() {
  document.querySelector('#product-images').addEventListener('change', selectedFile, false);
  selDiv = $("#selectedProductImages");
}

function selectedFile(e) {
  if (!e.target.files || !window.FileReader) return;

  selDiv.empty()
  var files = e.target.files;
  let filesArr = Array.prototype.slice.call(files);

  filesArr.forEach(function (f) {
    if (!f.type.match("image.*")) {
      return;
    }
    storedFile.push(f)
    var reader = new FileReader();
    reader.onload = function (e) {
      var html = "<div class=\"col-6 px-1 mb-2\"><div class=\"media\"><img class=\"align-self-start mr-3\" src=\"" + e.target.result + "\" alt=\"Generic placeholder image\" /> <div class=\"media-body\"><h5 class=\"mt-0\">" + f.name + "</h5> </div> </div></div>";
      selDiv.append(html);
    }
    reader.readAsDataURL(f);
  });
}

export function deleteImage() {
  $(".product-delete").click(function () {
    let product_id = $("#product-id").val();
    let image_id = $(this).find("input").val()
    delete_product_image(product_id, image_id, this)
  })
}

function delete_product_image(product_id, image_id, reference) {
  var CSRF_TOKEN = $("meta[name='csrf-token']").attr("content");

  $.ajax({
    url: '/product-images' + '?' + $.param({
      product_id: product_id,
      image_id: image_id
    }),
    type: 'DELETE',
    beforeSend: function (xhr) {
      xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    },
    success: function (data) {
      deleteSuccess(data, reference)
    },
    error: deleteError()
  })
}

function deleteSuccess(data, reference) {
  console.log('deleted data', data)
  $(reference).closest('.img-wrap').remove();
}

function deleteError(data) {
  console.log('errror data', data)
}

function setup_product() {
  let previousOptionValue = ""

  // This handle the variation theme selection
  $('#product_theme_id').on('change', function (e) {
    $('#theme_change_modal').modal(`show`);
  })

  $("#theme_change_confirm").click(function (e) {
    var optionSelected = $('#product_theme_id');
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

  $(".option-value")
    .blur(function (evt) {
      var td = $(evt.target)
      let option_value_id = td.data("option_value_id")
      let value = td[0].innerText
      if (value !== "")
        update_option_value(option_value_id, value)
      else {
        td.text(previousOptionValue)
      }
    })

  $(".option-value")
    .focusin(function (evt) {
      var td = $(evt.target)
      previousOptionValue = td[0].innerText
    })

  var product_id = $("#product_id").val();
  var theme_id = $("#product_theme_id").val();
  if (theme_id !== undefined && !(theme_id == ""))
    get_variation_options(theme_id, product_id)
}

function update_option_value(id, value){
    $.ajax({
      type: "POST",
      url: '/api/product_option_values/' + id,
      crossDomain: true,
      data: {value: value},
      success: function(response){
      }
    })
  }

  function get_variation_options(theme_id, product_id)
  {
    fetch('/api/option_types?theme_id=' + theme_id + "&product_id=" + product_id)
    .then(function(response) {
      return response.json();
    })
    .then(function (myJson) {
      $('#variation_options')
        .empty()
        .append(myJson.html)
    });
  $('#theme_change_modal').modal('hide');
}
