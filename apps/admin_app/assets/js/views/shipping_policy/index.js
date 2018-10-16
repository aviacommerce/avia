import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    $(".order_chb").change(function () {
      var checked = $(this).is(':checked');
      if (checked) {
        $(".order_chb").prop('checked', false);
        $(".order_chb").prop('value', false);
        $(this).prop('checked', true);
        $(this).prop('value', true);
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
    });

    $('#shipping_policy_form').submit(function () {
      $(".product_chb").prop('checked', true);
      $(".order_chb").prop('checked', true);
      $(".product_chb").prop('readOnly', true);
      $(".order_chb").prop('readOnly', true);
      return true; // return false to cancel form action
    });
    console.log('shipping policy index view mounted');
  }

  unmount() {
    super.unmount();

    console.log('shipping policy index view unmounted');
  }
}
