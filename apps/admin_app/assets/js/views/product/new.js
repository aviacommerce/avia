import MainView from '../main';

export default class View extends MainView {
    mount() {
      super.mount();
      document.getElementById("product_brand_id").selectedIndex = -1;
    }

    unmount() {
      super.unmount();
    }
  }