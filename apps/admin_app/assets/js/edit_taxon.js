export function editTaxon() {
  $(".mycontainer")
    .on("click", ".edit-taxon", function(){
      $("#edittaxon-modal").modal({show: true})
      var name = $(this).closest('table').siblings('.taxon_name').text();
      var id = $(this).closest('.item').data("taxon_id");
      $("#editform-taxon-id").val(id);
      $("#editform-taxon-name").val(name);
  })
}
