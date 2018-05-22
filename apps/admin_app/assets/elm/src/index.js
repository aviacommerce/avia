import './main.scss';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Main.embed(document.getElementById('elm-root'));

registerServiceWorker();
