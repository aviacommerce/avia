export function onSelectCountry() {
    $(document).delegate('#stock_location_country_id', 'change', function (event) {
      event.preventDefault();
      var country_id = $('#stock_location_country_id').val();
      $.ajax({
        url: `/fetch_states/${country_id}`,
        type: "GET",
        cache: false,
        success: function(json){
            $("#stock_location_state_id").empty().select2({ data: json.state_list });
        }
      });
    });
}
