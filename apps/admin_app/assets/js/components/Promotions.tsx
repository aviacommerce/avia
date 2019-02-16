import * as React from "react";
import { Link, Redirect} from 'react-router-dom'
import '../../css/promotions.css';

export class Promotions extends React.Component<{},any>{
    constructor(props){
        super(props);
        this.state={
            createpromotion:false,
            allPromotions:{}
        }
        this.fetchPromotions=this.fetchPromotions.bind(this)
        this.fetchGET = this.fetchGET.bind(this)
    }

    componentDidMount(){
        this.fetchPromotions()
    }

    fetchGET =(url)=>{
        return fetch(url,{
            credentials:'include',
            method:"GET",
            headers:{'Content-Type': 'application/json; charset=UTF-8'}
        }).then(res =>res.json())
    }

    fetchPromotions=()=>{
        var url="http://localhost:4000/api/promotions"
        this.fetchGET(url).then(response=>{
            var allPromotions=response
            this.setState({allPromotions:allPromotions})
            console.log('Success',JSON.stringify(response))})
        .catch(error=>console.error('Error',error))
    }

    render(){
        if(this.state.createpromotion){
            return <Redirect to="/create"/>
        }
        return(
            <div>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"/>
                <div className="TitlePromotion">
                    Promotions 
                    <button className="createButton" onClick={()=>{this.setState({createpromotion:true})}}><i class="fas fa-plus"></i> Add a Promotion </button>
                </div> 

            <table className="promotionstable" style={{width:"100%"}}>
                <tbody>
                    <tr className="headerrow">
                        <th style={{width:"12%"}}>ID</th>
                        <th style={{width:"12%"}}>Name</th>
                        <th style={{width:"12%"}}>Code</th>
                        <th style={{width:"20%"}}>Starts At</th>
                        <th style={{width:"20%"}}> Expires At</th>
                        <th style={{width:"12%"}}>Usage Count</th>
                        <th style={{width:"12%"}}>Usage Limit</th>
                    </tr>
                    {this.state.allPromotions["data"]===undefined?null:this.state.allPromotions["data"].map(promotion=>{return(
                    <tr className="promotionsrow">
                        <td className="id">{promotion["id"]}</td>
                        <td className="id" >{promotion["name"]}</td>
                        <td className="id" >{promotion["code"]}</td>
                        <td className="dates" >{promotion["starts_at"]}</td>
                        <td className="dates" >{promotion["expires_at"]}</td>
                        <td className="id" >{promotion["usage_count"]}</td>
                        <td className="id" >{promotion["usage_limit"]}</td>
                    </tr>)})}

                </tbody>
            </table> 

            </div>     
        )
    }
}