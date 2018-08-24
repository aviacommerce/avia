var selDiv
var storedFile = []

export function handleImageSelect() {
  document.querySelector('#product-images').addEventListener('change', selectedFile, false);
  selDiv = $("#selectedProductImages");
}

function selectedFile(e) {
  if(!e.target.files || !window.FileReader) return;

  selDiv.empty()
  var files = e.target.files;
  let filesArr = Array.prototype.slice.call(files);

 filesArr.forEach(function(f) {
    if(!f.type.match("image.*")) {
      return;
    }
    storedFile.push(f)
    var reader = new FileReader();
    reader.onload = function (e) {
      var html = "<img src=\"" + e.target.result + "\">" + f.name + "<br clear=\"left\"/>";
      selDiv.append(html);
    }
    reader.readAsDataURL(f);
  });
}

export function deleteImage() {
  $(".product-delete").click(function() {
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
    beforeSend: function(xhr) {
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
