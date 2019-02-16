import * as React from "react";
import { DatePicker, Input, Select, Button, InputNumber, Switch, Icon} from 'antd';
import 'antd/dist/antd.css';
import '../../css/promotions.css';
import {Link, Redirect} from 'react-router-dom';

export class PromotionsForm extends React.Component<{},any>{
    constructor(props){
        super(props);
        this.state={
            code:"",
            name:"",
            description:"",
            starts_at:"",
            expires_at:"",
            usageLimit:"",
            usageCount:"Nil",
            matchPolicy:"",
            activeStatus:false,
            success:false,
            ruleDown:false,
            addRule:false,
            actiondown:false,
            addedRules:[],
            availableRules:"",
            addAction:false,
            availableActions:"",
            availableCalculators:"",
            selectedRule:"",
            selectedCalc:"",
            lowRange:"",
            upRange:"",
            selectedProducts:"",
            productMatchPolicy:"",
            addedActions:[],
            selectedAction:"",
            selectedCalculator:""
        }

        this.handleStartDate = this.handleStartDate.bind(this);
        this.handleEndDate = this.handleEndDate.bind(this);
        this.handleSave = this.handleSave.bind(this);
        this.handleAddRule = this.handleAddRule.bind(this); 
        this.fetchPOST = this.fetchPOST.bind(this);
        this.handleAddAction = this.handleAddAction.bind(this);
        this.handleRule = this.handleRule.bind(this);
        this.renderRuleOptions = this.renderRuleOptions.bind(this);
        this.handleCalculator = this.handleCalculator.bind(this);
        this.renderCalculatorOptions = this.renderCalculatorOptions.bind(this);
        this.handleSaveRule = this.handleSaveRule.bind(this);
        this.onSuccess = this.onSuccess.bind(this);
        this.handleDeleteRule = this.handleDeleteRule.bind(this);
    }

    handleStartDate = (date,dateString)=>{
        const startDate = new Date(dateString)
        startDate.setHours(0,0,0)
        this.setState({starts_at:startDate})
    }

    handleEndDate = (date,dateString)=>{
        const endDate = new Date(dateString)
        endDate.setHours(0,0,0)
        this.setState({expires_at:endDate})
    }

    fetchPOST = (url,data)=>{
        return fetch(url,{
            credentials: 'include',
            method:'POST',
            body:JSON.stringify(data),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
        }).then(res =>res.json())
        
    }

    fetchGET =(url)=>{
        return fetch(url,{
            credentials:'include',
            method:"GET",
            headers:{'Content-Type': 'application/json; charset=UTF-8'}
        }).then(res =>res.json())
    }

    handleSave = () =>{
        var data = {
            "data":{
                "starta_at":this.state.starts_at,
                "expires_at":this.state.expires_at,
                "code":this.state.code,
                "name":this.state.name,
                "rules":[],
                "actions":[]
            }
        }
        var url = 'http://localhost:4000/api/promotions'
        this.fetchPOST(url,data).then(response=>{
            var arrofkeys=Object.keys(response)
            arrofkeys[0]=="errors"?this.onFail(response):this.onSuccess()
            console.log('Success',JSON.stringify(response))})
        .catch(error=>console.error('Error',error));
        
    }

    onSuccess =()=>{
        this.setState({success:true})
        alert("Saved Successfully!")
    }
    onFail=(response)=>{
        Object.keys(response).map((res)=>{
            var errormsg=""
            Object.keys(response[res]).map((res1)=>{
                errormsg=errormsg+res1+" "+response[res][res1][0]["message"]+"\n"
            })
            alert(errormsg)
        })
    }
    handleAddRule=()=>{
        
        this.setState({addRule:true})
        var url="http://localhost:4000/api/promo-rules"
        this.fetchGET(url).then(response=>{
            var availableRules=response
            this.setState({availableRules:availableRules})
            console.log('Success',JSON.stringify(response))})
        .catch(error=>console.error('Error',error));
        
    }

    handleAddAction=()=>{
        this.setState(prevState=>({
            actionDown:!prevState.actionDown,
            addAction:!prevState.addAction
        }))

        var url="http://localhost:4000/api/promo-actions"
        this.fetchGET(url).then(response=>{
            var availableActions=response
            this.setState({availableActions:availableActions})
            console.log('Success',JSON.stringify(response))})
        .catch(error=>console.error('Error',error));
        
        this.fetchGET("http://localhost:4000/api/promo-calculators").then(response=>{
            var availableCalculators=response
            this.setState({availableCalculators:availableCalculators})
            console.log('Success',JSON.stringify(response))})
        .catch(error=>console.error('Error',error));
    }

    handleRule=(rule)=>{
        console.log("module",rule)
        this.setState({selectedRule:rule})
        var url="http://localhost:4000/api/promo-rule-prefs"
        var data={"rule":rule}
        this.fetchPOST(url,data).then(response=>{}).catch(error=>console.error('Error',error));
    }

    handleSaveRule=(rule)=>{
        const addedRules=this.state.addedRules
        addedRules.push(rule)
        this.setState({addedRules:addedRules})
    }

    handleSaveAction=(action)=>{
        const addedActions=this.state.addedActions
        addedActions.push(action)
        this.setState({addedActions:addedActions})
    }

    handleDeleteRule=(index)=>{
        var addedRules=this.state.addedRules;
        addedRules.splice(index,1)
        this.setState({addedRules:addedRules})
    }

    handleDeleteAction=(index)=>{
        var addedActions=this.state.addedActions;
        addedActions.splice(index,1)
        this.setState({addedActions:addedActions})
    }

    renderRuleOptions=()=>{
        switch(this.state.selectedRule){
            case "Elixir.Snitch.Data.Schema.PromotionRule.OrderTotal":
                return(
                <div>
                    Lower Range:
                    <InputNumber placeholder="Lower Range" onChange={(value)=>{this.setState({lowRange:value})}} />
                    <br/>
                    Upper Range:
                    <InputNumber placeholder="Upper Range" onChange={(value)=>{this.setState({upRange:value})}}/>
                    <Button icon="save" onClick={()=>{this.setState({addRule:false,selectedRule:""});this.handleSaveRule({"name":"Order Item Total","value":{",LowerRange":this.state.lowRange,",UpperRange":this.state.upRange}});}}>Save</Button>
                </div>
                )
            case "Elixir.Snitch.Data.Schema.PromotionRule.Product":
            const Option = Select.Option;
                return(
                    <div>
                        Products:
                        <Select mode="multiple" onChange={(selectedProducts)=>{this.setState({selectedProducts:selectedProducts})}}>
                        <Option value="shoes">
                         shoes
                        </Option>
                        <Option value="tshirts">
                            tshirts
                        </Option>
                        <Option value="watches">
                            watches
                        </Option>

                        </Select>

                        Match Policy:
                        <Select onChange={(productMatchPolicy)=>{this.setState({productMatchPolicy:productMatchPolicy})}}>
                            <Option value = "all">All</Option>
                            <Option value="any">Any</Option>
                            <Option value="none">None</Option>
                        </Select> 
                        <Button icon="save" onClick={()=>{this.setState({addRule:false,selectedRule:""});this.handleSaveRule({"name":"Product Rule","value":{",Categories":this.state.selectedProducts,",Match Policy":this.state.productMatchPolicy}});}}>Save</Button>
                        
                    </div>
                )
            default:
                return null
        }
        
    }

    handleCalculator=(calc)=>{
        console.log("calcc",calc)
        this.setState({selectedCalc:calc})
        var url="http://localhost:4000/api/promo-calc-prefs"
        var data={"calculator":calc}
        this.fetchPOST(url,data).then(response=>{}).catch(error=>console.error('Error',error));
    }

    renderCalculatorOptions=()=>{
        console.log("calc",this.state.selectedCalc)
        switch(this.state.selectedCalc){
            case "Elixir.Snitch.Domain.Calculator.FlatRate":
                return(
                    <div>
                        Enter the Rate:
                        <InputNumber placeholder="FlatRate" onChange={(number)=>{this.setState({selectedCalculator:number})}}/>
                        <Button icon="save" onClick={()=>{this.setState({addRule:false,selectedAction:"",selectedCalc:"",selectedCalculator:""});this.handleSaveAction({"name":this.state.selectedAction,"value":{"Rate - ":this.state.selectedCalculator}});}}>Save</Button>
                    </div>

                )
            case "Elixir.Snitch.Domain.Calculator.FlatPercent":
                return(
                    <div>
                        Enter the Percent Amount:
                        <InputNumber placeholder="FlatPercent" onChange={(number)=>{this.setState({selectedCalculator:number})}}/>
                        <Button icon="save" onClick={()=>{this.setState({addRule:false,selectedAction:"",selectedCalc:"",selectedCalculator:""});this.handleSaveAction({"name":this.state.selectedAction,"value":{"Percent-":this.state.selectedCalculator}});}}>Save</Button>
                    </div>
                )
            default:
                return null
        }
    }

    render(){
        if(this.state.success){
            return <Redirect to="/"/>
        }
        const Option = Select.Option;
        let ruledown=this.state.ruleDown?"up":"down"
        let actiondown = this.state.actionDown?"up":"down"
        var a=this.state.selectedRule
        return(
            <div>                
              <div className="Title">Promotions Form </div>  
              <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"/>
              <div className="topnav"> 
                    <button style={{backgroundColor:"rgba()"}} onClick={this.handleSave}>Save</button>    
                    <Link to="/"><Icon type="arrow-left" />   Back</Link>
              </div>
              <div className="info">Promotion Information</div>
                <form className="form">
                    <div className="formrow">
                       Code <input placeholder = " Enter Code" onChange={(e)=>{this.setState({code:e.target.value})}}></input>
                    </div>
                    <div className="formrow">
                        Name <input placeholder = " Enter Name" onChange={(e)=>{this.setState({name:e.target.value})}} ></input>
                    </div>
                    <div className="formrow">
                        Description  <input placeholder = " Enter Description" onChange={(e)=>{this.setState({description:e.target.value})}}></input>
                    </div>
                    <div className="formrow">
                        Starts At:  <DatePicker onChange={this.handleStartDate} />
                    </div>
                    <div className="formrow"> 
                        Expires At: <DatePicker onChange={this.handleEndDate} />
                    </div>
                    <div className="formrow">
                    Usage Limit:
                        <InputNumber placeholder="Usage Limit" onChange={(usageLimit)=>{this.setState({usageLimit:usageLimit})}}/>
                    </div>
                    <div className="formrow">
                        <Input placeholder = {this.state.usageCount} addonBefore = "Current Usage" disabled={true} />
                    </div>
                    <div className="formrow">
                    Active?
                        <Switch onChange={()=>{ this.setState(prevState=>({activeStatus:!prevState.activeStatus}))}} />
                    </div>
                    <hr/>
                </form>
                
                    <div className="rulesandactions">
                    Rules   <Button style={{float:"right" marginRight:"35%"}} icon={ruledown} onClick={()=>{ this.setState(prevState=>({ruleDown:!prevState.ruleDown}))}}></Button>
                    </div>
                <form className="form">    
                    {this.state.ruleDown?(
                      <div className="formrow">
                      Match Policy:  
                        <Select onChange={(matchPolicy)=>{this.setState({matchPolicy:matchPolicy})}}>
                            <Option value = "all">All</Option>
                            <Option value="any">Any</Option>
                        </Select> 
                        Select Rule: 
                        {this.state.addRule?(<div>
                        <Select onChange={this.handleRule}>                            
                            {this.state.availableRules["data"]===undefined?null:this.state.availableRules["data"].map(rule=>{return(<Option value={rule["module"]}>{rule["name"]}</Option>)})}
                        </Select>
                        <Button onClick={()=>{this.setState({addRule:false,selectedRule:""})}}>Cancel</Button>
                        {
                            this.renderRuleOptions()
                        }
        
                         </div>
                        ):(<Button className="iconbutton" onClick={this.handleAddRule}>Add</Button>)}  
                        <br/>
                        Added Rules:
                        {this.state.addedRules.map((rule,index)=>{return(<div>{rule["name"]}-{ Object.keys(rule["value"]).map((res,index)=>{return(<div style={{display:"inline"}}>{res}-{rule["value"][res]}</div>)})}<Button icon="delete" onClick={(index)=>this.handleDeleteRule(index)}></Button></div>)})}
                      </div>
                    ):null}
                    <hr/>
                    </form>

                    <div className="rulesandactions">
                    Actions and Calculators <Button style={{float:"right" marginRight:"35%"}} icon={actiondown} onClick={this.handleAddAction}></Button>
                    <form className="form">
                    {this.state.addAction?
                    (<div className="formrow">
                    Action:
                    <Select onChange={(selectedAction)=>{this.setState({selectedAction:selectedAction})}}>
                        {this.state.availableActions["data"]===undefined?null:this.state.availableActions["data"].map(action=>{return(<Option value={action["name"]}>{action["name"]}</Option>)})}
                    </Select> 
                    Calulator:
                    <Select
                    onChange={this.handleCalculator}
                    >
                        {this.state.availableCalculators["data"]===undefined?null:this.state.availableCalculators["data"].map(calculator=>{return(<Option value={calculator["module"]}>{calculator["name"]}</Option>))} 
                    </Select>
                    {this.renderCalculatorOptions()}
                    Added Actions:
                    {this.state.addedActions.map((action,index)=>{return(<div>{action["name"]}-{ Object.keys(action["value"]).map((res,index)=>{return(<div style={{display:"inline"}}>{res}-{action["value"][res]}</div>)})}<Button icon="delete" onClick={(index)=>this.handleDeleteAction(index)}></Button></div>)})}
                     </div>
                    
                    ):
                        null}
                    </form>
                    </div>
                    <hr/>            
            </div>
            
        )
    }
}
