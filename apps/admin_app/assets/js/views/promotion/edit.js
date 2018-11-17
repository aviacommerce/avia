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
            toggle_element("rule_module_submit_btn");
            remove_rule_module_option(rule_module.selectedIndex);
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

      toggle_element("rule_module_submit_btn");

      document.getElementById("input_form").onchange = function() {
        toggle_element("rule_module_submit_btn");
      }

      document.onreadystatechange = function () {
        if (document.readyState == "complete") {
          var rule_module_list = get_existing_promotion_rule_modules();
          remove_rule_module_option_from(rule_module_list);
      }
    }
      }

      

    unmount() {
      super.unmount();
      // Specific logic here
      console.log('PromotionEditView unmounted');
    }
}


export function toggle_element(id) {
  var x = document.getElementById(id);
  if (x.disabled === true) {
    x.disabled = false;
  } else {
    x.disabled = true;
  }
}

export function remove_rule_module_option(index) {
  let rule_module = document.getElementById("rule_module");
  rule_module.remove(index);
  if (rule_module.length == 0) {
    toggle_element("rule_module_add_btn");
    toggle_element("rule_module");
  }
}

export function remove_rule_module_option_from(rule_module_list) {
  let rule_module = document.getElementById("rule_module");
  var i;
  var len = rule_module.length;
  let index_list = [];
  for(i=0; i < len; i++) {
    if (rule_module_list.indexOf(rule_module[i].value) != -1) {
      // remove_rule_module_option(i);
      index_list.push(i);
    }
  }

  for(i=0; i < index_list.length; i++) {
    remove_rule_module_option(index_list[i]);
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