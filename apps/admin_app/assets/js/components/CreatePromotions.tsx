import * as React from "react";
import { DatePicker, Select, Button, InputNumber, Switch } from 'antd';
import 'antd/dist/antd.css';
import { Promotions } from "./Promotions";
import * as moment from 'moment';
import { fetchGet, fetchPost, fetchPut, fetchProducts } from '../api';
import * as PromotionsConstants from '../constants';

export class PromotionsForm extends React.Component<any, any>{
    constructor(props) {
        super(props);
        this.state = {
            code: "",
            name: "",
            description: "",
            startsAt: null,
            expiresAt: null,
            usageLimit: "",
            usageCount: "Nil",
            matchPolicy: "",
            activeStatus: false,
            success: false,
            ruleDown: false,
            addRule: false,
            actiondown: false,
            addedRules: [],
            availableRules: "",
            addAction: false,
            availableActions: "",
            availableCalculators: "",
            selectedRule: "",
            selectedCalc: "",
            lowRange: "",
            upRange: "",
            selectedProducts: "",
            productMatchPolicy: "",
            addedActions: [],
            selectedAction: "",
            amount: "",
            rules: [],
            actions: [],
            failed: false,
            errors: {},
            back: false,
            calcData: {},
            ruleData: {},
            availableProducts:'',

        }
    }

    componentDidMount() {
        this.props.editResponse === undefined ? null : this.editPromotion(this.props.editResponse)
    }

    handleStartDate = (date, dateString) => {
        const startDate = new Date(dateString)
        startDate.setUTCHours(0,0,0)
        this.setState({ startsAt: startDate.toISOString() })
    }

    handleEndDate = (date, dateString) => {
        const endDate = new Date(dateString)
        endDate.setUTCHours(0, 0, 0)
        this.setState({ expiresAt: endDate.toISOString() })
    }

    handleSubmit = () => {
        let data = {
            "data": {
                "starts_at": this.state.startsAt,
                "expires_at": this.state.expiresAt,
                "code": this.state.code,
                "name": this.state.name,
                "rules": this.state.addedRules,
                "actions": this.state.addedActions,
                "usage_limit": this.state.usageLimit,
                "description": this.state.description,
                "active?": this.state.activeStatus,
            }
        }

        if (this.props.editResponse === undefined) {
            const PromotionsListURL = PromotionsConstants.PROMOTIONS_LIST_URL;
            fetchPost(PromotionsListURL, data).then(res => {
                if(res.status==422){
                    return this.onFail(res.json())
                }
                else if(res.ok){
                    return this.onSuccess()
                }
            })
            .catch(error => console.error('Error', error));
        }
        else {
            let id = this.props.editResponse["attributes"]["id"]
            const PromotionsUpdateURL = PromotionsConstants.PROMOTIONS_LIST_URL + id

            fetchPut(PromotionsUpdateURL, data).then(res => {
                if(res.status==422){
                    return this.onFail(res.json())
                }
                else if(res.ok){
                    return this.onSuccess()
                }
            })       
            .catch(error => console.error('Error', error))
        }
    }

    onSuccess = () => {
        this.setState({ success: true })
    }

    onFail = (res) => {
        res.then(response=>{
            this.setState({ failed: true, errors: response })
        })

    }

    handleAddRule = () => {
        this.setState({ addRule: true })
        const RulesListURL = PromotionsConstants.RULES_LIST_URL;
        fetchGet(RulesListURL).then(res => res.json()).then(response => {
            let availableRules = response
            this.setState({ availableRules: availableRules })
        })
        fetchProducts().then(
            result => this.setState({ availableProducts: result })
        )
    }

    handleAddAction = () => {
        this.setState(prevState => ({
            actionDown: !prevState.actionDown,
            addAction: !prevState.addAction
        }))

        const ActionsListURL = PromotionsConstants.ACTIONS_LIST_URL;
        fetchGet(ActionsListURL).then(res => res.json()).then(response => {
            let availableActions = response
            this.setState({ availableActions: availableActions })
        })
        .catch(error => console.error('Error', error));
        const CalculatorsListURL = PromotionsConstants.CALCULATORS_LIST_URL;
        fetchGet(CalculatorsListURL).then(res => res.json()).then(response => {
            let availableCalculators = response
            this.setState({ availableCalculators: availableCalculators })
        })
        .catch(error => console.error('Error', error));
    }

    handleRule = (rule) => {
        this.setState({ selectedRule: rule })
        const RulesPreferencesURL = PromotionsConstants.RULE_PREFERENCES_URL
        let data = { "rule": rule }
        fetchPost(RulesPreferencesURL, data).then(res => res.json())
            .then(response => { this.setState({ ruleData: response }) })
        .catch(error => console.error('Error', error));
    }

    handleSaveRule = (rule) => {
        const addedRules = this.state.addedRules
        addedRules.push(rule)
        this.setState({ addedRules: addedRules })
    }

    handleSaveAction = (action) => {

        const addedActions = this.state.addedActions
        addedActions.push(action)
        this.setState({ addedActions: addedActions })
    }

    handleDeleteRule = (index) => {
        let addedRules = this.state.addedRules;
        addedRules.splice(index, 1)
        this.setState({ addedRules: addedRules })
    }

    handleDeleteAction = (index) => {
        var addedActions = this.state.addedActions;
        addedActions.splice(index, 1)
        this.setState({ addedActions: addedActions })
    }

    handleProducts = (products) => {
        const product_list = []
        products.map(item => { product_list.push(parseInt(item)) })
        this.setState({ selectedProducts: product_list })
    }

    renderRuleOptions = () => {
        switch (this.state.selectedRule) {
            case PromotionsConstants.ORDER_TOTAL_MODULE:
                return (
                    <div>
                        Lower Range:
                    <InputNumber value={this.state.lowRange} placeholder="Lower Range" 
                        onChange={(value) => { this.setState({ lowRange: value }) }} 
                    />
                        <br />
                        Upper Range:
                    <InputNumber value={this.state.upRange} placeholder="Upper Range" 
                        onChange={(value) => { this.setState({ upRange: value }) }} 
                    />
                        <Button icon="save" 
                            onClick={() => { 
                                this.setState({ 
                                    addRule: false, 
                                    selectedRule: "" 
                                }); 
                                this.handleSaveRule({ 
                                    "name": PromotionsConstants.ORDER_TOTAL_NAME, 
                                    "module": this.state.selectedRule, 
                                    "preferences": { 
                                        "lower_range": this.state.lowRange, 
                                        "upper_range": this.state.upRange 
                                    }
                                }); 
                            }}>
                            Save       
                        </Button>
                    </div>
                )
            case PromotionsConstants.PRODUCT_RULE_MODULE:
                const Option = Select.Option;
                return (
                    <div>
                        Products:

                        <Select mode="multiple" 
                            onChange={(selectedProducts) => { this.handleProducts(selectedProducts) }}
                        >
                        {this.state.availableProducts["products"].map((productObject, index)=>{
                           return(
                             <Option key={index} value = {productObject["id"]}>
                                {productObject["category"]}
                            </Option>  
                           ) 
                        })}
                        </Select>

                        Match Policy:
                        <Select value={this.state.productMatchPolicy} 
                            onChange={(productMatchPolicy) => { this.setState({ productMatchPolicy: productMatchPolicy }) }}
                        >
                            <Option value="all">All</Option>
                            <Option value="any">Any</Option>
                            <Option value="none">None</Option>
                        </Select>
                        <Button icon="save" 
                            onClick={() => {
                                this.setState({ 
                                     addRule: false, 
                                     selectedRule: "" 
                                     }); 
                                this.handleSaveRule({
                                    "name": PromotionsConstants.PRODUCT_RULE_NAME, 
                                    "module": this.state.selectedRule, 
                                    "preferences": { 
                                        "product_list": this.state.selectedProducts, 
                                        "match_policy": this.state.productMatchPolicy 
                                    } 
                                }); 
                            }}>
                            Save
                        </Button>

                    </div>
                )
            default:
                return null;
        }
    }
    handleCalculator = (calc) => {
        this.setState({ selectedCalc: calc })
        const url = PromotionsConstants.CALCULATORS_PREFERENCES_URL
        var data = { "calculator": calc }
        fetchPost(url, data).then(res => res.json()).
        then(response => { this.setState({ calcData: response }) 
        })
        .catch(error => console.error('Error', error));
    }
    editPromotion = (editResponse) => {
        this.setState({
            code: editResponse["attributes"]["code"],
            name: editResponse["attributes"]["name"],
            activeStatus: editResponse["attributes"]["active?"],
            matchPolicy: editResponse["attributes"]["match_policy"],
            usageLimit: editResponse["attributes"]["usage_limit"],
            usageCount: editResponse["attributes"]["usage_count"],
            startsAt: editResponse["attributes"]["starts_at"],
            expiresAt: editResponse["attributes"]["expires_at"],
            description: editResponse["attributes"]["description"]
        })

        const rules = [];
        editResponse["rules"].map((ruleobject) => {
            let ruleobj = { name: '', module: '', preferences: {} }
            ruleobject["rule_data"].map((preferences) => {
                ruleobj["preferences"][preferences["key"]] = preferences["value"]
            })
            ruleobj["module"] = ruleobject["name"]
            switch (ruleobject["name"]) {
                case PromotionsConstants.ORDER_TOTAL_MODULE:
                    ruleobj["name"] = PromotionsConstants.ORDER_TOTAL_NAME
                    break;
                case PromotionsConstants.PRODUCT_RULE_MODULE:
                    ruleobj["name"] = PromotionsConstants.PRODUCT_RULE_NAME
                    break;
                default:
                    null;
            }
            rules.push(ruleobj)
        })
        this.setState({ addedRules: rules })

        const actions = []
        editResponse["actions"].map((actionobject) => {
            let actionobj = { name: '', module: '', preferences: { 
                calculator_module: '', calculator_preferences: { 
                    } 
                } 
            }
            actionobj["preferences"]["calculator_module"] = actionobject["action_data"][0]["value"]
            switch(actionobject["action_data"][0]["value"]){
                case PromotionsConstants.CALCULATOR_FLAT_RATE:
                    actionobj["preferences"]["calculator_preferences"]["amount"] = actionobject["action_data"][1]["value"]["data"][0]["value"]
                    break;
                case PromotionsConstants.CALCULATOR_FLAT_PERCENT:
                    actionobj["preferences"]["calculator_preferences"]["percent_amount"] = actionobject["action_data"][1]["value"]["data"][0]["value"]
                    break;
                default:
                    null;
            }
            
            actionobj["module"] = actionobject["name"]
            switch (actionobject["name"]) {
                case PromotionsConstants.ORDER_ACTION_MODULE:
                    actionobj["name"] = PromotionsConstants.ORDER_ACTION_NAME
                    break;
                case PromotionsConstants.LINE_ITEM_ACTION_MODULE:
                    actionobj["name"] = PromotionsConstants.LINE_ITEM_ACTION_NAME
                    break;
                default:
                    null;
            }
            actions.push(actionobj)
        })
        this.setState({ addedActions: actions })
    }

    render() {
        if (this.state.success || this.state.back) {
            return <Promotions />
        }
        const Option = Select.Option;
        return (
            <div className="list-container">
                <div className="pt-3 pb-0 pr-3 pl-3 back" > 
                        <img src="/images/left-arrow.svg" width="20" height="20" className="d-inline-block align-top" alt="" />
                        <a onClick={() => { this.setState({ back: true }) }}>Promotions</a>
                </div>
                <h4 className="p-3 m-0">Add a new Promotion</h4>
                <div className="col-12">
                    <div className="card col-12">
                        <form>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label required">
                                        Code
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div className="form-group">
                                            <div className="label required">Code</div>
                                            {this.state.failed && this.state.errors["errors"]["code"] != undefined ? (
                                                <div>
                                                    <input className="form-control is-invalid" value={this.state.code} 
                                                        onChange={(e) => { this.setState({ code: e.target.value }) }} 
                                                    />
                                                    <span className="invalid-feedback">{this.state.errors["errors"]["code"][0]["message"]}</span>
                                                </div>
                                            ) : (
                                                    <div>
                                                        <input className="form-control" value={this.state.code} 
                                                            onChange={(e) => { this.setState({ code: e.target.value }) }} 
                                                        />
                                                    </div>
                                                )}

                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label required">
                                        Name
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div className="form-group">
                                            <div className="label required">Name</div>
                                            {this.state.failed && this.state.errors["errors"]["name"] != undefined ? (
                                                <div>
                                                    <input className="form-control is-invalid" value={this.state.name} 
                                                        onChange={(e) => { this.setState({ name: e.target.value }) }} 
                                                    />
                                                    <span className="invalid-feedback">{this.state.errors["errors"]["name"][0]["message"]}</span>
                                                </div>
                                            ) : (
                                                    <div>
                                                        <input className="form-control" value={this.state.name} 
                                                            onChange={(e) => { this.setState({ name: e.target.value }) }} 
                                                        />
                                                    </div>
                                                )}
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label">
                                        Description
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div className="form-group">
                                            <div className="label">Description</div>
                                            <input className="form-control" value={this.state.description} 
                                                onChange={(e) => { this.setState({ description: e.target.value }) }} 
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label required">
                                        Starts At:
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div>
                                            <div className="label required">Starts At:</div>
                                            {this.state.failed && this.state.errors["errors"]["starts_at"] != undefined ? (
                                                <div>
                                                    <DatePicker className = "form-control is-invalid" value={this.state.startsAt == null ? null : moment.utc(this.state.startsAt)} 
                                                    onChange={this.handleStartDate} 
                                                    />
                                                    <span className="invalid-feedback">{this.state.errors["errors"]["starts_at"][0]["message"]}</span>
                                                </div>                                                
                                            ):(
                                                <DatePicker value={this.state.startsAt == null ? null : moment.utc(this.state.startsAt)} 
                                                onChange={this.handleStartDate} 
                                            />
                                            )
                                        }                                            
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label required">
                                        Expires At:
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div>
                                            <div className="label required">Expires At:</div>
                                            {this.state.failed && this.state.errors["errors"]["expires_at"] != undefined ? (
                                                <div>
                                                    <DatePicker className = "form-control is-invalid" value={this.state.expiresAt == null ? null : moment.utc(this.state.expiresAt)} 
                                                    onChange={this.handleEndDate} 
                                                    />
                                                    <span className="invalid-feedback">{this.state.errors["errors"]["expires_at"][0]["message"]}</span>
                                                </div>                                                
                                            ):(
                                                <DatePicker value={this.state.expiresAt == null ? null : moment.utc(this.state.expiresAt)} 
                                                onChange={this.handleEndDate} 
                                            />
                                            )
                                        }
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label">
                                        Usage Limit
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div className="form-group">
                                            <div className="label">Usage Limit</div>
                                            {this.state.failed && this.state.errors["errors"]["usage_limit"] != undefined ? (
                                                <div>
                                                    <input className="form-control is-invalid" value={this.state.usageLimit} 
                                                        onChange={(e) => { this.setState({ usageLimit: e.target.value }) }} 
                                                    />
                                                    <span className="invalid-feedback">{this.state.errors["errors"]["usage_limit"][0]["message"]}</span>
                                                </div>
                                            ) : (
                                                    <div>
                                                        <input className="form-control" value={this.state.usageLimit} 
                                                            onChange={(e) => { this.setState({ usageLimit: e.target.value }) }} 
                                                        />
                                                    </div>
                                                )
                                            }
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label">
                                        Usage Count
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div className="form-group">
                                            <div className="label">Usage Count</div>
                                            <input className="form-control" value={this.state.usageCount} disabled />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row">
                                <label className="col-sm-3 col-form-label">
                                    <div className="label">
                                        Active?
                                    </div>
                                </label>
                                <div className="col-sm-9">
                                    <div className="col-sm-12">
                                        <div className="form-group">
                                            <div className="label">Active Status</div>
                                            {this.state.activeStatus?(
                                                <div>
                                                    <Switch defaultChecked onChange={() => { this.setState(prevState => ({ activeStatus: !prevState.activeStatus })); }} />
                                                </div>
                                            ):(
                                                <Switch onChange={() => { this.setState(prevState => ({ activeStatus: !prevState.activeStatus })); }} />
                                            )}                                          
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="form-group row stickformbutton">
                                <div className="col-sm-10">
                                    <button type="button" className="btn btn-primary submit-btn float-right" 
                                        onClick={this.handleSubmit}> 
                                        Submit
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                    <h4 className="p-3 m-0"> Add a Rule 
                        <i 
                            onClick={() => { 
                                this.setState(prevState => ({ ruleDown: !prevState.ruleDown })); 
                                this.handleAddRule() }} 
                            className="fa fa-angle-down downangle">
                        </i>
                    </h4>
                    {this.state.ruleDown ? (
                        <div className="card col-12">
                            <form>
                                <div className="form-group row">
                                    <label className="col-sm-3 col-form-label">
                                        <div className="label">
                                            Match Policy
                                        </div>
                                    </label>
                                    <div className="col-sm-9">
                                        <select className="form-control" 
                                            onChange={(e) => { this.setState({ matchPolicy: e.target.value }) }} 
                                            placeholder="Select"
                                        >
                                            <option value="all" >All</option>
                                            <option value="any">Any</option>
                                        </select>
                                    </div>
                                </div>
                                <div className="form-group row">
                                    <label className="col-sm-3 col-form-label">
                                        <div className="label">
                                            Rule
                                        </div>
                                    </label>
                                    <div className="col-sm-9">
                                        <select className="form-control" defaultValue=" " onChange={(e) => { this.handleRule(e.target.value) }}>
                                            {this.state.availableRules["data"] === undefined ? null : 
                                                this.state.availableRules["data"].map((rule, index) => { 
                                                    return (<option key={index} value={rule["module"]}>{rule["name"]}</option>) 
                                                    })
                                            }
                                        </select>
                                        {this.renderRuleOptions()}
                                    </div>
                                </div>
                                <div className="form-group row">
                                    <label className="col-sm-3 col-form-label">
                                        <div className="label">
                                            Added Rules
                                        </div>
                                    </label>
                                    <div className="col-sm-9">
                                        {this.state.addedRules.map((rule, index) => { 
                                            return (<div key={index}>{rule["name"]}-{Object.keys(rule["preferences"]).map((res, index) => { 
                                                        return (<div key={index} style={{ display: "inline" }}>{res}-{rule["preferences"][res]}</div>) })}
                                                        <Button icon="delete" 
                                                            onClick={(index) => this.handleDeleteRule(index)}>
                                                        </Button>
                                                    </div>
                                                ) 
                                            })
                                        }
                                    </div>
                                </div>
                            </form>
                        </div>
                    ) : null}
                    <h4 className="p-3 m-0"> Add an Action 
                        <i onClick={this.handleAddAction} className="fa fa-angle-down downangle">
                        </i>
                    </h4>
                    {this.state.addAction ? (
                        <div className="card col-12">
                            <form>
                                <div className="form-group row">
                                    <label className="col-sm-3 col-form-label">
                                        <div className="label">
                                            Action
                                        </div>
                                    </label>
                                    <div className="col-sm-9">
                                        <select className="form-control" onChange={(action) => { this.setState({ selectedAction: [action[0], action[1]] }) }}>
                                            {this.state.availableActions["data"] === undefined ? null : this.state.availableActions["data"].map((action, index) => {
                                                return (
                                                    <option key={index} value={[action["name"], action["module"]]}>{action["name"]}</option>
                                                )
                                            })}
                                        </select>
                                    </div>
                                </div>
                                <div className="form-group row">
                                    <label className="col-sm-3 col-form-label">
                                        <div className="label">
                                            Calculator
                                        </div>
                                    </label>
                                    <div className="col-sm-9">
                                        <select className="form-control" onChange={(e) => { this.handleCalculator(e.target.value) }}>
                                            {this.state.availableCalculators["data"] === undefined ? null : this.state.availableCalculators["data"].map((calculator, index) => {
                                                return (
                                                    <option key={index} value={calculator["module"]}>{calculator["name"]}</option>
                                                )
                                            })}                                               
                                        </select>
                                        {this.state.calcData["data"] === undefined ? null : (
                                            <div>{
                                                this.state.calcData["data"]["data"][0]["key"]}
                                                <input onChange={(e) => { this.setState({ amount: e.target.value }) }} />
                                                <Button icon="save" onClick={() => {
                                                    this.setState({ addRule: false, selectedCalc: "", selectedCalculator: "", calcData: "" });
                                                    this.handleSaveAction({ 
                                                        "name": this.state.selectedAction[0], 
                                                        "module": this.state.selectedAction[1], 
                                                        "preferences": { 
                                                            "calculator_module": this.state.selectedCalc, 
                                                            "calculator_preferences": { 
                                                                [this.state.calcData["data"]["data"][0]["key"]]: this.state.amount 
                                                                } 
                                                            } 
                                                        });
                                                }}>
                                                    Save
                                    </Button>
                                            </div>)
                                        }
                                    </div>
                                </div>
                                <div className="form-group row">
                                    <label className="col-sm-3 col-form-label">
                                        <div className="label">
                                            Added Actions
                                        </div>
                                    </label>
                                    <div className="col-sm-9">
                                        {this.state.addedActions.map((action, index) => { return (<div key={index}>{action["name"]}-<div style={{ display: "inline" }}>{action["preferences"]["calculator_preferences"]["amount"] === undefined ? (<div>percent_amount - { action["preferences"]["calculator_preferences"]["percent_amount"]}</div>) : (<div>amount - { action["preferences"]["calculator_preferences"]["amount"]}</div>)}</div><Button icon="delete" onClick={(index) => this.handleDeleteAction(index)}></Button></div>) })}
                                    </div>
                                </div>
                            </form>
                        </div>
                    ) : null}
                </div>
            </div>
        )
    }
}
