import MainView from '../main';
import socket from './../../socket';

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
      let channel = socket.channel("order:search", {})

      channel.on(`order:search:${window.userToken}`, payload => {
        $(".main").html(payload.body);
        this.mount();
      })

      channel.join()

      $(document).on('change', '#order_search_box', function () {
        if ($("#order_search_box").val.length > 0) { // don't send empty msg.
          $("#order-search-button").text("loading....");
          channel.push('order:search', { // send the message to the server on "ping" channel
            term: $("#order_search_box").val(),
            start_date: $("#selected_start_date").val(),
            end_date: $("#selected_end_date").val()
          });
          $("#order_search_box").val = ''; // reset the message input field for next message.
        }
      });
      $(document).on('change', '#selected_state', function () {    
        $(".orders-list").html("");
        $(".orders-list").addClass("loader");
        channel.push('order:search', { // send the message to the server on "ping" channel
          term: $("#selected_state").val(),
          start_date: $("#selected_start_date").val(),
          end_date: $("#selected_end_date").val()
        });
      });
      $(document).on('change', '#selected_start_date, #selected_end_date', function () {
        $(".orders-list").html("");
        $(".orders-list").addClass("loader");
        channel.push(`order:search`, { // send the message to the server on "ping" channel
          start_date: $("#selected_start_date").val(),
          end_date: $("#selected_end_date").val()
        });
      });
    }

    unmount() {
      console.log('order index unmounted');
      super.unmount();
    }
  }
