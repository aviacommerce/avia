import MainView from '../main';
import socket from './../../socket';

export default class View extends MainView {
  mount() {
    super.mount();
    let channel = socket.channel("product:search", {})
    paginatedSearch(channel)
    document.getElementById("product-sort-select").onchange = function () {
      window.location.replace(this.value);
    };

    document.getElementById('product-listing-draft').onclick = function () {
      window.location.replace(this.value);
    };

    document.getElementById('product-listing-active').onclick = function () {
      window.location.replace(this.value);
    };

    document.getElementById('product-listing-inactive').onclick = function () {
      window.location.replace(this.value);
    };

    channel.on(`product:search:${window.userToken}`, payload => {
      $(".products_list").html(payload.body);
      paginatedSearch(channel);
      $("#search-button").html('<i class="fa fa-search"></i>');
    })

    channel.join()

    $(document).on('change', '#search_box', function () {
      if ($("#search_box").val.length > 0) { // don't send empty msg.
        $("#search-button").text("loading....");
        channel.push('product:search', { // send the message to the server on "ping" channel
          term: $("#search_box").val(),
          page: 1
        });
        // $("#search_box").val = ''; // reset the message input field for next message.
      }
    });
  }

  unmount() {
    super.unmount();
  }
}

export function paginatedSearch(channel) {
  $('a.pagination-btn').on('click', (e) => {
    var btn = $(e.currentTarget);
    var page = btn.data("page");
    var search_value = $("#search_box").val()
    if(search_value) {
      channel.push('product:search', { // send the message to the server on "ping" channel
        term: search_value,
        page: page
      });
    }else {
      $.ajax({
        url: btn.data("route"),
        type: 'GET',
        success: (data) => {
          $('.main').empty().append(data);
          paginatedSearch(channel)
        }
      })
    }
  });
}