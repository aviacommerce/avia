import MainView from '../main';

export default class View extends MainView {
    mount() {
      super.mount();
  
      // Specific logic here
      console.log('PromotionEditView mounted');
      document.getElementById("rule_module_add_btn").onclick = function(){
        var CSRF_TOKEN = $("meta[name='csrf-token']").attr("content");
        let target_div = $("#rule_module_content");
        let rule_module = document.getElementById("rule_module");
        let form_type = {option: rule_module.value};
        $.ajax({
          url: `${window.location.pathname}/rule/render-form`,
          type: 'GET',
          beforeSend: function(xhr) {
            xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
          },
          data: form_type,
          success: function(data){
            target_div.empty().append(data.html);
          }
        });
        
        document.getElementById("rule_module_submit_btn").onclick = function(){
          let input_form = document.getElementById("input_form");
          input_form.action = input_form.action + "/rule/create";
          input_form.enctype = "multipart/form-data";
          input_form.method = "post";
          document.getElementById("input_form").submit();          
        }
      }
      }

      

    unmount() {
      super.unmount();
      // Specific logic here
      console.log('PromotionEditView unmounted');
    }
}
