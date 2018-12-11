import MainView from '../main';
import { addEventToProductFormButtons } from './publish_helper'

export default class View extends MainView {
  mount() {
    super.mount();

    // Specific logic here

    addEventToProductFormButtons();
  }

  unmount() {
    super.unmount();

    // Specific logic here
  }
}