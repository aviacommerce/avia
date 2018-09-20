import MainView from '../main';

export default class View extends MainView {
    mount() {
      super.mount();
      console.log('order view mounted');
      $('.order-tab .nav-link').on('click', function(e) {
        e.preventDefault();
        $('.order-tab .nav-link').removeClass('active');
        $(this).addClass('active')

        let url = $(this).attr('href');
        let target_div = $('.list')
        $.ajax({
          url: url,
          type: 'GET',
          success: function(data) {
            target_div.empty().append(data.html)
          }
        })
      })
    }

    unmount() {
      console.log('order index unmounted');
      super.unmount();
    }
  }
