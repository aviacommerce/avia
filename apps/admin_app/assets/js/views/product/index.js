import MainView from '../main';

export default class View extends MainView {
    mount() {
      super.mount();
      document.getElementById("product-sort-select").onchange = function(){
        window.location.replace(this.value);
      };

      document.getElementById('product-listing-draft').onclick = function() {
        window.location.replace(this.value);
      };

      document.getElementById('product-listing-active').onclick = function() {
        window.location.replace(this.value);
      };

      document.getElementById('product-listing-inactive').onclick = function() {
        window.location.replace(this.value);
      };
    }

    unmount() {
      super.unmount();
    }
  }
