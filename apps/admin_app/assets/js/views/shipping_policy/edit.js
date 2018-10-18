import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    $(document).ready(function () {
      var order_length = $(".order_chb").length;
      var product_length = $(".product_chb").length;
      for (var i = 0; i < product_length; i++) {
        if ($(".product_chb")[i].value == "true") {
          $(".product_chb")[i].checked = $(".product_chb")[i].value;
        }
      }

      for (var i = 0; i < order_length; i++) {
        if ($(".order_chb")[i].value == "true") {
          $(".order_chb")[i].checked = $(".order_chb")[i].value;
        }
      }
    });

    $(".order_chb").change(function () {
      var checked = $(this).is(':checked');
      if (checked) {
        $(".order_chb").prop('checked', false);
        $(".order_chb").prop('value', false);
        $(this).prop('checked', true);
        $(this).prop('value', true);
      }
      else {
        $(".order_chb").prop('checked', false);
        $(".order_chb").prop('value', false);
        $(this).prop('checked', false);
        $(this).prop('value', false);
      }

    });

    $(".product_chb").change(function () {
      var checked = $(this).is(':checked');
      if (checked) {
        $(".product_chb").prop('checked', false);
        $(".product_chb").prop('value', false);
        $(this).prop('checked', true);
        $(this).prop('value', true);
      }
      else {
        $(".product_chb").prop('checked', false);
        $(".product_chb").prop('value', false);
        $(this).prop('checked', false);
        $(this).prop('value', false);
      }
    });

    $('#shipping_policy_form').submit(function () {
      $(".product_chb").prop('checked', true);
      $(".order_chb").prop('checked', true);
      $(".product_chb").prop('readOnly', true);
      $(".order_chb").prop('readOnly', true);
      return true;
    });
  }

  unmount() {
    super.unmount();

  }
}
