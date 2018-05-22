import 'select2' // eslint-disable-line no-unused-vars

export default function select2Selector() {
  $("[data-init-plugin='select2']").each(function () {
    $(this).select2();
  })
}
