import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    this.onSelectCountry();
  }

  unmount() {
    super.unmount();
  }

  onSelectCountry() {
    $(document).delegate('#tax_config_default_country_id', 'change', function (event) {
      event.preventDefault();
      var country_id = $('#tax_config_default_country_id').val();
      $.ajax({
        url: `/fetch_states/${country_id}`,
        type: "GET",
        cache: false,
        success: function(json){
            $("#tax_config_default_state_id").empty().select2({ data: json.state_list });
        }
      });
    });
  }

}
