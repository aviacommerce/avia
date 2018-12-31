import MainView from '../main';
import { onSelectCountry } from "./fetch_states";

export default class View extends MainView {
    mount() {
      super.mount();
      onSelectCountry();
    }

    unmount() {
      super.unmount();
    }
}
