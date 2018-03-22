import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<JiviGame channel={channel} />, root);
}

class JiviGame extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;

    this.state = {
                player1: null,
                player2: null,
		players: null,
		field: null
               };
    this.current_player = "";
 
    this.channel.join()
        .receive("ok", resp => { this.current_player = resp.player;
				 this.putPlayerName(this.current_player);
				})
        .receive("error", resp => { console.log("Unable to join", resp) });

    this.channel.on("render_challenge", resp => this.gotView(resp));  
	 
    this.channel.on("render_fight", resp => this.gotView(resp));  

    this.channel.on("put_player_name", resp => this.gotView(resp));
  }

  gotView(view) {
    console.log("New view", view);
    this.setState(view.game);
  }

  putPlayerName(name) {
         this.channel.push("player", { name: name })
         .receive("ok", this.gotView.bind(this));
  }

  fight(trigger) {
	 this.channel.push("fight", { trigger: trigger })
         .receive("ok", this.gotView.bind(this));
  }

  select(jivi, player) {
    this.channel.push("select", { jivi: jivi, player: player })
	.receive("ok", this.gotView.bind(this));
  }
 
  challenge(category) {
    this.channel.push("challenge", { category: category })
	.receive("ok", this.gotView.bind(this));
  }

  render() {
    let player1_jivis = "";
    let player2_jivis = "";  
    let field_jivis = "";
    let player1, player2 = ""
    console.log(this.state.players);
    console.log(this.current_player);

    if(this.state.player1==null){ player1_jivis=""; }
    if(this.state.player1 != null) {
      player1_jivis = _.map(this.state.player1.jivis, (jivi) => {
        return <Jivi jivi={jivi} root={this} player={this.state.player1}/>;
	  });
    }
    if(this.state.player2 != null) {
      player2_jivis = _.map(this.state.player2.jivis, (jivi) => {
        return <Jivi jivi={jivi} root={this} player={this.state.player2}/>;
          });
    }
    if(this.state.field != null) {
      field_jivis = _.map(this.state.field, (jivi) => {
        return <Jivi jivi={jivi} root={this} />;
          });
    }
    if(this.state.players != null && this.current_player == this.state.players[0]){
	player1 = this.current_player;
	player2 = "Other Player";
    }
    else if(this.state.players != null && this.state.players.length > 1){
	player1 = "Other Player";
	player2 = this.state.players[1];
    }
    
    return (
      <div className="container">
       <div className="row">
        <div className="col-md-3">
         <div className="player">
	  <h3>{player1}</h3>
          <p>{ player1_jivis }</p>
          <button type="button" onClick={() => this.fight(1)}>Ready</button>
         </div>
        </div>
        <div className="col-md-6">
          <div className="field">
	    <Field root={this}/>
          </div>
        </div>
        <div className="col-md-3">
         <div className="player">
	  <h3>{player2}</h3>
          <p>{ player2_jivis }</p>
          <button type="button" onClick={() => this.fight(2)}>Ready</button>
         </div>
        </div>
       </div>
      </div>
    );
  }
}

function Jivi(params) {
  let root = params.root;
  let state = root.state;
  let jivi = params.jivi;
  let player = params.player;
  if(state.player1==null) {
    return (<div><p>Loading---</p></div>);
  }
 // if(player.name!=root.current_player){
   // console.log(player.name);
    //return (<div className="col-md"><div className="jivi-selected"></div></div>);
 // }
  if(jivi.selected) {
  return (<div className="col-md">
             <div className="jivi-selected" onClick={() => root.select(jivi, player)}>
                <p> Jivi    : {jivi.name} </p>
                <p> Fire    : {jivi.fire} </p>
                <p> Water   : {jivi.water} </p>
		<p> Electric: {jivi.electricity} </p>
		<p> Muscle  : {jivi.muscle} </p> 
             </div>
          </div>);
  }
  return (<div className="col-md">
             <div className="jivi-front" onClick={() => root.select(jivi, player)}>
                <p> Jivi    : {jivi.name} </p>
                <p> Fire    : {jivi.fire} </p>
                <p> Water   : {jivi.water} </p>
		<p> Electric: {jivi.electricity} </p>
		<p> Muscle  : {jivi.muscle} </p> 
             </div>
          </div>);
}

function FieldJivi(params) {
  let root = params.root;
  let state = root.state;
  let jivi = params.jivi;
  if(state.player1==null) {
    return (<div><p>Loading---</p></div>);
  }
  return (<div className="col-md">
             <div className="jivi-selected">
             </div>
          </div>);
}

function Field(params){
  let state = params.root.state;
  let field_jivis = "";
  if(state.field != null) {
      field_jivis = _.map(state.field, (jivi) => {
           return <FieldJivi root={params.root} jivi={jivi}/>
          });
    }
  if(field_jivis!=""){
    return (<div> {field_jivis}
		<p><button type="button" className="btn btn-warning" onClick={() => params.root.challenge("fire")}>Fire</button>
               <button type="button" className="btn btn-info" onClick={() => params.root.challenge("water")}>Water</button>
               <button type="button" className="btn btn-danger" onClick={() => params.root.challenge("electricity")}>Electricity</button>
               <button type="button" className="btn btn-dark" onClick={() => params.root.challenge("muscle")}>Muscle</button></p></div>);
  }
  else{return(<div></div>);}
}

