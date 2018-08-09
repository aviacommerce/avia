export function getPaymentMethod() {
  document.getElementById("payment-provider").onchange = function(){
    let target_div = $("#preferences");
    let payment_data = {provider: this.value};
    $.ajax({
      url: '/payment-provider-inputs',
      type: 'POST',
      data: payment_data,
      success: function(data){
        target_div.empty().append(data.html);
      }
    });
  }
}
