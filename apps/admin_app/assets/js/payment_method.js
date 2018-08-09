export function getPaymentMethod() {
  document.getElementById("payment-provider").onchange = function(){
    var CSRF_TOKEN = $("meta[name='csrf-token']").attr("content");
    let target_div = $("#preferences");
    let payment_data = {provider: this.value};
    $.ajax({
      url: '/payment-provider-inputs',
      type: 'POST',
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
      },
      data: payment_data,
      success: function(data){
        target_div.empty().append(data.html);
      }
    });
  }
}
