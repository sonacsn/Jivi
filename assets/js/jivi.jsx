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
		field: null,
                challenged: 0
               };
    this.current_player = "";
 
    this.channel.join()
        .receive("ok", resp => { this.current_player = resp.player;
				 this.putPlayerName(this.current_player);
				})
        .receive("error", resp => { console.log("Unable to join", resp) });

    this.channel.on("render_showjivi", resp => this.gotView(resp));  

    this.channel.on("render_challenge", resp => this.gotView(resp));  
	 
    this.channel.on("render_fight", resp => this.gotView(resp));  

    this.channel.on("put_player_name", resp => this.gotView(resp));
  
    this.channel.on("push_select", resp => this.gotView(resp));
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
 
  showjivi(category) {
    this.channel.push("showjivi", { category: category })
	.receive("ok", this.gotView.bind(this));
  }

  challenge(category) {
    this.channel.push("challenge", { category: category })
	.receive("ok", this.gotView.bind(this));
  }

  challengeAccepted(category) {
    this.showjivi(category)
    setTimeout(() => {
	this.challenge(category)
    }, 2000);
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
        <Message root={this}/>
       </div>
       <div className="row">
        <div className="col-md-3">
         <div className="player">
	  <h3><p>{player1}</p></h3>
          { player1_jivis }
	 <ButtonFun1 root={this} player={this.state.player1} />
         </div>
        </div>
        <div className="col-md-6">
          <div className="field">
	    <Field root={this} />
          </div>
        </div>
        <div className="col-md-3">
         <div className="player">
	  <h3><p>{player2}</p></h3>
          { player2_jivis }
          <ButtonFun1 root={this} player={this.state.player2}/>
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

  if(player.name!=root.current_player){
    return (<div className="col-md"><div className="jivi-selected"></div></div>);
  }
  let classname = "jivi-front";
  if(jivi.selected)
        classname = "jivi-selected";
  console.log("selected?", jivi);

  return (<div className="col-md">
             <div><img src={"/images/" + jivi.name} alt="Image not available" width="60" height="60"/></div>
             <div className={classname} onClick={() => root.select(jivi, player)}>
                <p> Jivi    : {jivi.name} </p>
                <p> Fire    : {jivi.fire} </p>
                <p> Water   : {jivi.water} </p>
		<p> Electric: {jivi.electricity} </p>
		<p> Muscle  : {jivi.muscle} </p>
             </div>
          </div>);
}

function ButtonFun1(params) {
  let root = params.root;
  let state = params.root.state;
  let player = params.player;
 
  if(player == null || player.name != params.root.current_player){
	return (<div></div>)
  }
  //if any jivis of player is selected 
  let jivi = _.where(player.jivis, {selected: true});

  //if any of player's jivi is in field
  let in_field = _.where(state.field, {owner: player.name});
  if(jivi.length != 0 && in_field.length == 0){
	return (<button type="button" onClick={() => params.root.fight(player.name)}>Ready</button>)
  }
  return <div> </div>
}

function Message(params) {
  let state = params.root.state;
  if(state.player1 != null && state.player1.turn == true) {
    return Message1(params)
  } else if(state.player2 != null && state.player2.turn == true) {
    return Message2(params)
  } else {
    return (<div> </div>)
  } 
}

function Message1(params) {
  let state = params.root.state;
  if(state.player1 != null && state.player2 != null) {
    if(state.player1.turn == true && state.player1.ready == 0) {
      return (<h3> Waiting for Player1 to select Jivi </h3>)
    } else if(state.player1.ready == 1) {
      return (<h3> Waiting for Player 1 to Send Jivi to Field </h3>)
    } else if(state.player1.ready == 2 && state.player2.ready == 0) {
      return (<h3> Waiting for Player 2 to select Jivi </h3>)
    } else if(state.player1.ready == 2 && state.player2.ready == 1) {
      return (<h3> Waiting for Player 2 to Send Jivi to Field </h3>)
    } else if(state.player1.ready == 2 && state.player2.ready == 2) {
      return (<h3> Waiting to Challenge </h3>)
    } else {
      return (<h3> No message </h3>)   
    }
  }
  return (<div> </div>)
}

function Message2(params) {
  let state = params.root.state;
  if(state.player1 != null && state.player2 != null) {
    if(state.player2.turn == true && state.player2.ready == 0) {
      return (<h3> Waiting for Player2 to select Jivi </h3>)
    } else if(state.player2.ready == 1) {
      return (<h3> Waiting for Player 2 to Send Jivi to Field </h3>)
    } else if(state.player2.ready == 2 && state.player1.ready == 0) {
      return (<h3> Waiting for Player 1 to select Jivi </h3>)
    } else if(state.player2.ready == 2 && state.player1.ready == 1) {
      return (<h3> Waiting for Player 1 to Send Jivi to Field </h3>)
    } else if(state.player2.ready == 2 && state.player1.ready == 2) {
      return (<h3> Waiting to Challenge </h3>)
    } else {
      return (<h3> No message </h3>)   
    }
  }
  return (<div> </div>)
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

function ShowFieldJivi(params) {
  let root = params.root;
  let state = root.state;
  let jivi = params.jivi;
  if(state.player1==null) {
    return (<div><p>Loading---</p></div>);
  }
  return (<div className="col-md">
             <div><img src={"/images/" + jivi.name} alt="Image not available" width="60" height="60"/></div> 
             <div className="jivi-selected">
               <p> Jivi     : {jivi.name} </p>
               <p> Fire     : {jivi.fire} </p>
               <p> Water    : {jivi.water} </p>
               <p> Electric : {jivi.electricity} </p>
               <p> Muscle   : {jivi.muscle} </p>
             </div>
          </div>);
}

function Field(params){
  let state = params.root.state;
  let field_jivis = "";
  if(state.field != null) {
      field_jivis = _.map(state.field, (jivi) => {
           if(state.challenged == 0) {
              return <FieldJivi root={params.root} jivi={jivi}/>
           } else {
              return <ShowFieldJivi root={params.root} jivi={jivi}/>
           }
          });
    }
  if(field_jivis!=""){
    return (<div> 
		{field_jivis}
		<ChallengeButtons root={params.root} player={params.root.current_player} />
            </div>);
  }
  else{return(<div></div>);}
}

function ChallengeButtons(params){
  let root = params.root;
  let state = root.state;
  let cur_playername = root.current_player;;
  let player = "";
  if(!_.contains(state.players, cur_playername))
	return (<div></div>);
  if(cur_playername == state.player1.name)
	player = state.player1;
  else
	player = state.player2;
  if(player.turn && state.field.length==2 && state.challenged==0){
    return(<div>
 		<p><button type="button" className="btn btn-warning" onClick={() => params.root.challenge("fire")}>Fire</button>
                   <button type="button" className="btn btn-info" onClick={() => params.root.challenge("water")}>Water</button>
                   <button type="button" className="btn btn-danger" onClick={() => params.root.challenge("electricity")}>Electricity</button>
                   <button type="button" className="btn btn-dark" onClick={() => params.root.challenge("muscle")}>Muscle</button></p>
	  </div>);
  }
  else
    return (<div></div>);
}

