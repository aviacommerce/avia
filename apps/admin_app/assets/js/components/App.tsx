import * as React from "react";
// import { Hello } from "./Hello";
import {PromotionsForm} from "./CreatePromotions"
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom'
import {Promotions} from "./Promotions"
class App extends React.Component<{},any> {
  constructor(props){
    super(props)
    this.state={hello:"hi"}
  }
  render() {
    return (
      <div>
        <Router basename = '/promotions'>
          <Switch>
            <Route exact path="/" component={Promotions} />
            <Route exact path="/create" component={PromotionsForm}/>
          </Switch>
        </Router>
        
        {/* <Hello compiler="Typescript" framework="React"/> */}
      </div>
    );
  }
}

export default App;
