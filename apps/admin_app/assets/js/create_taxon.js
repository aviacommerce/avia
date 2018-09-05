export function createTaxon() {
  $(".mycontainer")
    .on("click", ".add-taxon", function(){
      $("#taxon-modal").modal({show: true})
      var id = $(this).closest('.item').data("taxon_id");
      $("#form-taxon-id").val(id);
  })

  $(".taxonform").on("submit", function(event) {
    event.preventDefault();
    var tid = $("#form-taxon-id").val();
    let target_div = $(`.item[data-taxon_id=${tid}]`);
    // let target_div = $("#taxon-modal").parent();
    $.ajax({
      url: '/taxonomy',
      type: "POST",
      data: $(this).serialize(),
      success: function(result) {
        $("#taxon-modal").modal('hide');
        target_div.append(result.html);
      }
    });
  });
}
