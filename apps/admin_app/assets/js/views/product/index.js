import MainView from '../main';
import socket from './../../socket';

export default class View extends MainView {
  mount() {
    super.mount();
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

    // Now that you are connected, you can join channels with a topic:
    let channel = socket.channel("product:search", {})

    channel.on(`product:search:${window.userToken}`, payload => {
      $(".main").html(payload.body);
      this.mount();
    })

    channel.join()

    $(document).on('change', '#search_box', function () {
      if ($("#search_box").val.length > 0) { // don't send empty msg.
        $("#search-button").text("loading....");
        channel.push('product:search', { // send the message to the server on "ping" channel
          term: $("#search_box").val()
        });
        $("#search_box").val = ''; // reset the message input field for next message.
      }
    });
  }

  unmount() {
    super.unmount();
  }
}
