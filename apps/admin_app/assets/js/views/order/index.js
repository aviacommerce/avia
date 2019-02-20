import MainView from '../main';
import socket from './../../socket';

export default class View extends MainView {
  mount() {
    super.mount();
    let channel = socket.channel("order:search", {})
    paginatedSearch(channel);
    let order_list_container = $('.list');

    $('.order-tab .nav-link').on('click', (e) => {
      e.preventDefault();
      var elm = $(e.currentTarget);
      $('.order-tab .nav-link').removeClass('active');
      elm.addClass('active');
      var category = elm.text().toLowerCase();
      $.ajax({
        url: "/orders",
        type: 'GET',
        data: { category: category },
        dataType: 'json',
        success: (data) => {
          order_list_container.empty().append(data.html)
          paginatedSearch(channel);
        }
      })
    })

    $('.selected-option').on('change', (e) => {
      var sort_order = $(e.currentTarget).val();
      var category = $(".nav-tabs .active").text().toLowerCase();
      $.ajax({
        url: `/orders`,
        type: 'GET',
        dataType: 'json',
        data: { category: category , sort: sort_order, },
        success: (data) => {
          order_list_container.empty().append(data.html);
          paginatedSearch(channel);
        }
      })
    });

    channel.on(`order:search:${window.userToken}`, payload => {
      $('.list').empty().append(payload.body);
      paginatedSearch(channel);
      removeLoadedData();
    })

    channel.join()

    $('#order_search_box').on('change', () => {
      if (!$("#order_search_box").val.length) { // don't send empty msg.
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

    $('#selected_state').on('change', () => {
      $(".orders-list").html("");
      $(".orders-list").addClass("loader");
      var payload = {
        term: $("#selected_state").val(),
        start_date: $("#selected_start_date").val(),
        end_date: $("#selected_end_date").val()
      };
      channel.push('order:search', payload); // send the message to the server on "ping" channel  
    });

    $('#selected_start_date, #selected_end_date').on('change', () => {
      $(".orders-list").html("");
      $(".orders-list").addClass("loader");
      var payload = { // send the message to the server on "ping" channel
        start_date: $("#selected_start_date").val(),
        end_date: $("#selected_end_date").val()
      }
      channel.push(`order:search`, payload); // send the message to the server on "ping" channel
    });


  }

  unmount() {
    console.log('order index unmounted');
    super.unmount();
  }
}

function toSnakeCase(params) {
  Object.keys(params).forEach(key => {
    const value = params[key];
    delete params[key];
    params[key.replace(/([a-zA-Z])(?=[A-Z])/g, '$1_').toLowerCase()] = value;
  })
  return params;
}

function removeLoadedData() {
  $("#order-search-button").html('<i class="fa fa-search"></i>');
  $(".orders-list").removeClass("loader");
}

export function paginatedSearch(channel) {
  $('a.pagination-btn').on('click', (e) => {
    var btn = $(e.currentTarget);
    var page = btn.data("page");
    var category = btn.parent().data("category") || "pending"
    var params = $('.pagination-params').data()
    var paginated_params = Object.assign({}, toSnakeCase(params));
    if (typeof paginated_params["start_date"] === 'undefined') {
      $.ajax({
        url: "/orders",
        type: 'GET',
        data: { category: category, page: page, sort: params["sort"] },
        dataType: 'json',
        success: (data) => {
          $('.list').empty().append(data.html);
          paginatedSearch(channel);
        }
      })
    } else {
      params["page"] = page
      $(".orders-list").html("");
      $(".orders-list").addClass("loader");
      channel.push('order:search', params);
    }
  });
}
