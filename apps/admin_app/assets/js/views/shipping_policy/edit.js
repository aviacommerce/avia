import MainView from '../main';

export default class View extends MainView {

  mount() {
    super.mount();

    $(document).ready(function() {
      let ref = $('input[type=radio]:checked');

      if(ref.data('code') == "fso") {
        return ;
      }

      ref.siblings(".rule-preferences").toggle("slide");
      $(".shipping-rules-check").show()
      $(".shipping-rules-check").appendTo(ref.parent("div.shipping-rules").find(".appended-rules"));
      $(".shipping-rules-check").find(".rule-preferences").show()
    })

    $(".shipping-rule-radio").click(function() {
      if ($(this).data('code') != "fso") {
        radioButtonEvents($(this));
        appendRule($(this));
      } else {
        radioButtonEvents($(this));
        $(".shipping-rule-checkbox").prop('checked', false);
      }
    })
  }

  unmount() {
    super.unmount();
  }
}

function radioButtonEvents(ref) {
  $(".shipping-rule-radio").prop('checked', false)
  $(".rule-preferences").hide();
  ref.prop('checked', true);
  ref.prop('value', true);
  ref.siblings(".rule-preferences").toggle("slide");
}

function appendRule(ref) {
  $(".shipping-rules-check").show()
  $(".shipping-rules-check").appendTo(ref.parent("div.shipping-rules").find(".appended-rules"));
  $(".shipping-rules-check").find(".rule-preferences").show()
}
