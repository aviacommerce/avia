import * as React from "react";
import { PromotionsForm } from "./CreatePromotions"
import { fetchGet, fetchPut } from '../api';
import * as myconstants from '../constants';
import '@babel/polyfill'
export class Promotions extends React.Component<any, any>{
    constructor(props) {
        super(props);
        this.state = {
            createpromotion: false,
            allPromotions: {},
            editValues: {},
            editId: "",
            editCode: "",
            editPromotion: false,
            editResponse: {}
        }
    }

    componentDidMount() { 
        this.fetchPromotions()
    }

    fetchPromotions = () => {
        fetchGet(myconstants.PROMOTIONS_LIST_URL).then(res => res.json()).then(response => {
            var allPromotions = response
            this.setState({ allPromotions: allPromotions })
        })
    }

    onArchive = (index, id) => {
        const url = "/api/promo/" + id + "/archive"

        fetchPut(url, null).then(res => res.json()).then(response => {
            console.log('Success', JSON.stringify(response))
        }).catch(error => console.error('Error', error))

        var allPromotions = this.state.allPromotions;
        allPromotions["data"].splice(index, 1)
        this.setState({ allPromotions: allPromotions })
    }

    onEdit = (id) => {
        const url = "/api/promotions/" + id + "/edit"
        fetchGet(url).then(res => res.json()).then(response => {
            this.setState({ editResponse: response })
            console.log("onEdit", response)
        }).catch(error => console.error('Error', error))

        this.setState({ editId: id, editPromotion: true })

    }

    render() {
        if (this.state.createpromotion) {
            return <PromotionsForm />
        }
 
        if (this.state.editPromotion) {
            if (this.state.editResponse["attributes"] != undefined) {
                return <PromotionsForm editResponse={this.state.editResponse} />
            }

        }
        return (
            <div className="list-container">
                <div className="row m-0 list-header">
                    <div className="col-10 p-0">
                        <h2>Promos</h2>
                    </div>
                    <div className="col-2 p-0 float-right text-right">
                        <div className="btn btn-primary" onClick={() => { this.setState({ createpromotion: true }) }}><i className='fas fa-plus'></i> Add a Promotion</div>
                    </div>
                </div>
                <div className="row m-0 list">
                    {this.state.allPromotions["data"] === undefined ? null : this.state.allPromotions["data"].map((promotion, index) => {
                        return (
                            <div key={index} className="table-contaner col-12 p-3 mb-2">
                                <div className="row" id="spree_zone_1">

                                    <div className="col-11 p-0">
                                        <div className="media">
                                            <div className="checkbox mx-3">
                                                <label>
                                                    <input type="checkbox" value="" />
                                                    <span className="cr"><i className="cr-icon fa fa-check"></i></span>
                                                </label>
                                            </div>
                                            <div className="media-body">
                                                <div className="row">
                                                    <div className="col-5">   {promotion["name"]}   </div>
                                                    <div className="col-4">                       </div>
                                                    <div className="col-3">  {promotion["code"]}</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="col-1 float-right">
                                        <div className="dropdown col-12 p-0 float-right options-container">
                                            <a className="p-2 dropdown-toggle options" href="#" role="button" id="dropdownMenuLink" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                <i className="fa fa-cog"></i>
                                            </a>
                                            <div className="dropdown-menu dropdown-menu-right" aria-labelledby="dropdownMenuLink">
                                                <div className="dropdown-item" onClick={() => { this.onEdit(promotion["id"]) }}>Edit</div>
                                                <div className="dropdown-item" onClick={() => { this.onArchive(index, promotion["id"]) }} >Archive</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )
                    })}

                </div>
            </div>
        )
    }
}