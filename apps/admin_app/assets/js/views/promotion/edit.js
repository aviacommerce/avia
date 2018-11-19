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
            target_div.append(data.html);
            toggle_element("rule_module_submit_btn", false);
            toggle_element("rule_module_add_btn", true);
            disable_rule_module_option(rule_module.selectedIndex);
          }
        });
      }

      document.getElementById("rule_module_submit_btn").onclick = function(){
        let input_form = document.getElementById("input_form");
        input_form.action = input_form.action + "/rule/create";
        input_form.enctype = "multipart/form-data";
        input_form.method = "post";
        document.getElementById("input_form").submit();          
      }

      toggle_element("rule_module_submit_btn", true);
      toggle_element("rule_module_add_btn", true);

      document.getElementById("input_form").oninput = function() {
          toggle_element("rule_module_submit_btn", false);        
      }

      document.getElementById("rule_module").onchange = function() {
        let rule_module = document.getElementById("rule_module");
        if (rule_module.selectedIndex > 0) {
          toggle_element("rule_module_add_btn", false);
        }
        if (rule_module.selectedIndex == 0) {
          toggle_element("rule_module_add_btn", true);
        }
      }

      document.onreadystatechange = function () {
        if (document.readyState == "complete") {
          var rule_module_list = get_existing_promotion_rule_modules();
          disable_rule_module_option_from(rule_module_list);
          let rule_module = document.getElementById("rule_module");
          rule_module.selectedIndex = 0;
      }
    }
      }

      

    unmount() {
      super.unmount();
      // Specific logic here
      console.log('PromotionEditView unmounted');
    }
}


export function toggle_element(id, is_disabled) {
  var x = document.getElementById(id);
  x.disabled = is_disabled;
}

export function disable_rule_module_option(index) {
  let rule_module = document.getElementById("rule_module");
  rule_module[index].disabled = true;
  rule_module.selectedIndex = 0;
}

export function disable_rule_module_option_from(rule_module_list) {
  let rule_module = document.getElementById("rule_module");
  var i;
  var len = rule_module.length;
  for(i=0; i < len; i++) {
    if (rule_module_list.indexOf(rule_module[i].value) != -1) {
      disable_rule_module_option(i);
    }
  }
}

export function get_existing_promotion_rule_modules() {
  let rule_module_names = document.getElementsByClassName("rule_module_name");

  var i;
  let module_list = [];
  for(i=0; i < rule_module_names.length; i++) {
    module_list.push(rule_module_names[i].value);
  }

  return module_list;
}