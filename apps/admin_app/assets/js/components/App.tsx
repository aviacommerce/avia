import * as React from "react";
import { BrowserRouter as Router, Route } from 'react-router-dom'
import {Promotions} from "./Promotions"
class App extends React.Component<any,any> {
  constructor(props){
    super(props)
  }
  render() {
    return (
      <div>
        <Router basename = '/promotions'>
            <Route exact path="/" component={Promotions} />
        </Router>
      </div>
    );
  }
}

export default App;
