import MainView from '../main';
import select2Selector from './../../form-helpers/select2-selector';

export default class View extends MainView {
    mount() {
      super.mount();
      $(".mycontainer").on("click", ".edit-taxon", function(){
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
      // Specific logic here
      console.log('TaxonomyTaxonomyView mounted');
    }

    unmount() {
      super.unmount();

      // Specific logic here
      console.log('TaxonomyTaxonomyView unmounted');
    }
}
