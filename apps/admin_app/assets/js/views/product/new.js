import MainView from '../main';
import { addEventToProductFormButtons } from './publish_helper'

export default class View extends MainView {
  mount() {
    super.mount();

    // Specific logic here
    console.log('ProductNewView mounted');

    addEventToProductFormButtons();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('ProductNewView unmounted');
  }
}