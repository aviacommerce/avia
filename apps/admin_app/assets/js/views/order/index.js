import MainView from '../main';

export default class View extends MainView {
    mount() {
      super.mount();
      let target_div =  $('.list');
      $('.order-tab .nav-link').on('click', function(e) {
        e.preventDefault();
        $('.order-tab .nav-link').removeClass('active');
        $(this).addClass('active')
        var url = $(this).attr('href');
        $.ajax({
          url: url,
          type: 'GET',
          success: function(data) {
            target_div.empty().append(data.html)
          }
        })
      })
      $('.selected-option').on('change', function() {
        var sort_order = this.value;
        var url = $(".nav-tabs .active").text().toLowerCase();
        $.ajax({
          url: `/orders/${url}`,
          type: 'GET',
          data: {sort: sort_order},
          success: function(data) { 
            target_div.empty().append(data.html);
          }
        })
      });

    }

    unmount() {
      console.log('order index unmounted');
      super.unmount();
    }
  }
