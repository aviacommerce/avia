import select2Selector from './form-helpers/select2-selector';

export function editTaxon() {
  $(".mycontainer")
    .on("click", ".edit-taxon", function(){
      $("#edittaxon-modal").modal({show: true})
      var name = $(this).closest('table').siblings('.taxon_name').text();
      var id = $(this).closest('.item').data("taxon_id");
      $(`#taxon-edit-loader`).addClass(`loader`).show();

      fetch('http://localhost:4000/api/taxon/' + id)
      .then(function(response) {
        return response.json()
      })
      .then(function(json) {
        $(`#taxon-edit-body`)
        .empty()
        .append(json.html)
        $(`#taxon-edit-loader`).removeClass(`loader`).hide();
        select2Selector()
      })
  })
}
