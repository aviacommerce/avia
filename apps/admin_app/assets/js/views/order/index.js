import MainView from '../main';
import socket from './../../socket';

export default class View extends MainView {
  mount() {
    super.mount();
    let target_div = $('.list');
    $('.order-tab .nav-link').on('click', function (e) {
      e.preventDefault();
      $('.order-tab .nav-link').removeClass('active');
      $(this).addClass('active');
      var category = $(this).text().toLowerCase();
      $.ajax({
        url: "/orders",
        type: 'GET',
        data: { category: category },
        dataType: 'json',
        success: function (data) {
          target_div.empty().append(data.html)
        }
      })
    })
    $('.selected-option').on('change', function () {
      var sort_order = this.value;
      var url = $(".nav-tabs .active").text().toLowerCase();
      $.ajax({
        url: `/orders/${url}`,
        type: 'GET',
        data: { sort: sort_order },
        success: function (data) {
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
        var payload = { // send the message to the server on "ping" channel
          term: $("#order_search_box").val(),
          start_date: $("#selected_start_date").val(),
          end_date: $("#selected_end_date").val()
        }
        channel.push('order:search', payload); // send the message to the server on "ping" channel
        $("#order_search_box").val = ''; // reset the message input field for next message.
      }
    });
    $(document).on('change', '#selected_state', function () {
      $(".orders-list").html("");
      $(".orders-list").addClass("loader");
      var payload = {
        term: $("#selected_state").val(),
        start_date: $("#selected_start_date").val(),
        end_date: $("#selected_end_date").val()
      };
      channel.push('order:search', payload); // send the message to the server on "ping" channel  
    });
    $(document).on('change', '#selected_start_date, #selected_end_date', function () {
      $(".orders-list").html("");
      $(".orders-list").addClass("loader");
      var payload = { // send the message to the server on "ping" channel
        start_date: $("#selected_start_date").val(),
        end_date: $("#selected_end_date").val()
      }
      channel.push(`order:search`, payload); // send the message to the server on "ping" channel
    });
    $(document).on('click', '.pagination .pagination-btn', function (e) {
      e.preventDefault();
      var page = $(this).data("page")
      var category = $(this).parent().data("category") || "pending"
      var params = $('.pagination-params').data();
      if (params["startDate"] != undefined){
        params["page"] = page
        $(".orders-list").html("");
        $(".orders-list").addClass("loader");
        channel.push('order:search', params);
      }else{
        $.ajax({
          url: "/orders",
          type: 'GET',
          data: { category: category, page: page },
          dataType: 'json',
          success: function (data) {
            $('.list').empty().append(data.html)
          }
        })
      }
    });
  }

  unmount() {
    console.log('order index unmounted');
    super.unmount();
  }
}
