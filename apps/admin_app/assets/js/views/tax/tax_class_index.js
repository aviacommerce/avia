import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    this.newClass();
    this.postAction();
    this.editClass();
  }

  unmount() {
    super.unmount();
  }

  newClass() {
    $("#new-class-button").click(function(event) {
      let target_div = $("#tax-class-form")
      let modal = $('#addModal')
      $.ajax({
        url: '/tax/tax-classes/new',
        type: "GET",
        cache: false,
        success: function(data){
          target_div.empty().append(data.html);
          $('span#modal-header').empty().append("Create Tax Class")
          modal.modal('show');
        }
      });
    })
  }

  editClass() {
    $("a#edit-class-button").click(function(event) {
      event.preventDefault()
      let url = $(this).attr('href')
      let target_div = $("#tax-class-form")
      let modal = $('#addModal')
      $.ajax({
        url: url,
        type: "GET",
        cache: false,
        success: function(data){
          target_div.empty().append(data.html);
          $('span#modal-header').empty().append("Edit Tax Class")
          modal.modal('show');
        }
      });
    })
  }

  postAction() {
    $("#tax-class-form").on('submit','#tax_class_form', function(event) {
      event.preventDefault();
      var CSRF_TOKEN = $("meta[name='csrf-token']").attr("content");
      let form = $('#tax_class_form')
      let action = form.attr('action')
      let method = form.attr('method')
      let form_data = form.serialize()
      let list_div = $('.list-group')
      let target_div = $("#tax-class-form")
      let modal = $('#addModal')

      $.ajax({
        url: action,
        type: method,
        beforeSend: function(xhr) {
          xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
        },
        data: form_data,
        success: function(data){
          if (action === '/tax/tax-classes/new') {
            list_div.append(data.html)
            modal.modal('hide')
          }
          else {
            let id = $(data.html).filter("li").attr('id')
            let list_id = `li#${id}`
            $(list_id).replaceWith(data.html)
            modal.modal('hide')
          }
        },
        error: function(data){
          target_div.empty().append(data.responseJSON.html);
          modal.modal('show');
        }
      });
    });
  }

}
