import MainView from '../main';
import select2Selector from './../../form-helpers/select2-selector';

export default class View extends MainView {
    mount() {
      super.mount();
  
      //Specific logic 
      toggle_display("state-zone-list");
      set_label_text();
      $("#active-zone").on('change', function() {
        toggle_zone_list();
        set_label_text();
      });      
    }
  
    unmount() {
      super.unmount();
    }
}

export function toggle_zone_list() {
  toggle_display("country-zone-list");
  toggle_display("state-zone-list");
  select2Selector();
}

export function set_label_text() {
  var zone = document.getElementById("active-zone");
  var zonetext = zone[zone.selectedIndex].innerText;
  var zonevalue = zone[zone.selectedIndex].value;
  document.getElementById("list-label").innerText = zonetext;
}

export function toggle_display(id) {
  var x = document.getElementById(id);
  if (x.style.display === "none") {
    x.style.display = "block";
  } else {
    x.style.display = "none";
  }
} 
