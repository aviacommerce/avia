import MainView from '../main';

export default class View extends MainView {
    mount() {
      super.mount();
      handle_category_click();
      $(`#category_loader`).removeClass(`loader`).hide();

      // Specific logic here
      console.log('ProductProduct_categoryView mounted');
    }

    unmount() {
      super.unmount();

      // Specific logic here
      console.log('ProductProduct_categoryView unmounted');
    }
}

//--------------------------------------------------
// Functions for product category selection page
// --------------------------------------------------

function get_categories(id)
{
  $(`#category_loader`).addClass(`loader`).show();
  fetch('/api/categories/' + id)
  .then(function(response) {
    return response.json();
  })
  .then(function(json){
    $(`#category_selection`)
    .append(json.html)
    $(`#category_loader`).removeClass(`loader`).hide();
  })
}

function handle_category_click(){
    $(`#category_selection`)
    .on("click", "li", function(e){
      let clicked_li = $(e.target);

      //clear existing active li
      var ul =  clicked_li.closest("ul");

      ul
      .children()
      .each(function(){
        $(this).removeClass(`active`);
      });

      //remove all categories after
      var card = ul.closest('.card--content');
      card.nextAll().remove();

      var next_taxon_id = clicked_li.data('taxon_id');
      clicked_li.addClass('active')

      get_categories(next_taxon_id);
    })
  }
