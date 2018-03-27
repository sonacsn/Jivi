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
		killed: null,
                challenged: 0
               };
    this.current_player = "";
    this.category = "";
    this.channel.join()
        .receive("ok", resp => { this.current_player = resp.player;
				 this.putPlayerName(this.current_player);
				})
        .receive("error", resp => { console.log("Unable to join", resp) });

    this.channel.on("render_showjivi", resp => {this.category=resp.category;
						this.gotView(resp)});  

    this.channel.on("render_challenge", resp => {this.category="";
						 this.gotView(resp)});  

    this.channel.on("render_chat", resp => this.gotView(resp)); 
	 
    this.channel.on("render_fight", resp => this.gotView(resp));  

    this.channel.on("put_player_name", resp => this.gotView(resp));
  
    this.channel.on("push_select", resp => this.gotView(resp));
  }

  gotView(view) {
    this.setState(view.game);
  }

  putPlayerName(name) {
         this.channel.push("player", { name: name })
         .receive("ok", this.gotView.bind(this));
  }

  chat(player, msg, form) {
    form.reset();
    if(msg != null) {
       this.channel.push("chat", { player: player, msg:msg })
        .receive("ok", this.gotView.bind(this));
    }
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
    this.category = category;
    this.showjivi(category)
    setTimeout(() => {
        this.category = "";
	this.challenge(category)
    }, 8000);
  }

  render() {
    let player1_jivis = "";
    let player2_jivis = "";  
    let field_jivis = "";
    let killed_jivis = "";
    let player1, player2 = ""
    let isObserver = false;
    
    if(this.state.player1==null || this.state.player2==null)
	return (<div>Loading....</div>);

      player1_jivis = _.map(this.state.player1.jivis, (jivi, key) => {
        return <Jivi jivi={jivi} key={key}  root={this} player={this.state.player1}/>;
	  });

      player2_jivis = _.map(this.state.player2.jivis, (jivi,key) => {
        return <Jivi jivi={jivi} key={key} root={this} player={this.state.player2}/>;
          });

    if(this.state.field != null) {
      field_jivis = _.map(this.state.field, (jivi, key) => {
        return <Jivi jivi={jivi} key={key} root={this} />;
          });
    }
    if(this.current_player == this.state.players[0]){
	player1 = this.current_player;
	player2 = "Other Player";
    }
    else if(this.state.players.length==2 && this.current_player==this.state.players[1]){
	player1 = "Other Player";
	player2 = this.state.players[1];
    }
    else{
        player1 = this.state.players[0];
        player2 = this.state.players[1];
        isObserver = true;
    }
    let msg = "";
    if(isObserver)
        msg = "Logged in as Observer";

    return (
	
        <div className="container">
          <div className="message"><Message root={this}/></div>
          <div className="row">
            <div className="col-md-3">
              <div className="player">
	        <h3><p style={{color:'orchid'}}>{player1}</p></h3>
	        <ButtonFun1 root={this} player={this.state.player1} />
          	{ player1_jivis }
              </div>
            </div>
            <div className="col-md-6">
	      <div className="container">
	        <div className="row-md">
	          <div className="col-md">
                    <div className="field">
                	{msg}
	        	<Field root={this} />
                    </div>
		    <Killed root={this}/>
                  </div>
	          <div className="col-md">
                    <MsgFun root={this} />
              	    <ChatFun root={this} player={this.state.player1} />
              	    <ChatFun root={this} player={this.state.player2} />
            	  </div>
		</div>
  	      </div>
            </div>
            <div className="col-md-3">
              <div className="player">
	        <h3><p style={{color:'orange'}}>{player2}</p></h3>
                <ButtonFun1 root={this} player={this.state.player2}/>
          	{ player2_jivis }
              </div>
            </div>
          </div>
        </div>
    );
  }
}    

function Killed(params) {
  let state = params.root.state;
  let killed_jivis;
   if(state.killed != null) {
      killed_jivis = _.map(state.killed, (jivi,key) => {
        let name="p2";
        if(jivi.owner==state.player1.name)
            name="p1";
        return <div key={key} className={name}><img src={"/images/" + jivi.name} alt="Image not available" width="60" height="60"/></div>;
          });
    }

  if(killed_jivis!=null && killed_jivis.length>0)
    return (<div><h3>Killed Jivis</h3>
	    <div className="flex-container killed">
              {killed_jivis}
            </div></div>);
  else
    return (<div></div>);



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
    return (<div className="col-md jivi-back"><img src={"/images/jiviball"} alt="Image not available" width="70%" height="200px"/></div>);
  }
  let classname = "jivi-front";
  if(jivi.selected){
	if(jivi.owner==state.player1.name)
            classname = "jivi-selected p1";
	else
	    classname = "jivi-selected p2";
  }
  return (<div className="col-md">
             <div><img src={"/images/" + jivi.name} alt="Image not available" width="60" height="60"/></div>
             <div className={classname}  onClick={() => root.select(jivi, player)}>
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
  if(state.challenged!=2 && jivi.length != 0 && in_field.length == 0){
	return (<button type="button" className="btn btn-secondary btn-sm" onClick={() => params.root.fight(player.name)}>Ready</button>)
  }
  return <div> </div>
}

function ChatFun(params) {
  let root = params.root;
  let state = params.root.state;
  let player = params.player;
  let msg;
  let form;
  if(player.name == root.current_player) {
     return(<form  ref={(el) => form = el}>
             <input type="text"  placeholder="Let's chat!" ref={(input)=>msg=input}/>
             <button type="button" className="btn btn-secondary btn-sm" onClick={() => params.root.chat(player.name, msg.value,form)}>Chat</button>
           </form>)
  }
  return(<div></div>)
}

function MsgFun(params) {
  let root = params.root;
  let state = params.root.state;
  let chat = state.chat;
  let chatbox = _.map(chat, (obj, key) => {
        if(obj.player==state.player1.name)
		return (<div key={key} className="chatp1">{obj.msg}</div>);
        else
		return (<div key={key} className="chatp2">{obj.msg}</div>);
          });

     return(<form id="chat-form">
             <div id="owner-msg">{chatbox}</div>
           </form>)
}

function FieldJivi(params) {
  let root = params.root;
  let state = root.state;
  let jivi = params.jivi;
  if(state.player1==null) {
    return (<div><p>Loading---</p></div>);
  }
  return (<div className="col-md">
             <div className="onfield">
             </div>
          </div>);
}

function ShowFieldJivi(params) {
  let root = params.root;
  let state = root.state;
  let jivi = params.jivi;
  let catf,catw,cate,catm;
  catf=catw=cate=catm="";
  if(state.player1==null) {
    return (<div><p>Loading---</p></div>);
  }
  if(root.category!=""){
  catf=catw=cate=catm="hide";
  switch(root.category){
    case "fire":
	catf="category";
	break;
    case "water":
	catw="category";
	break;
    case "electricity":
	cate="category";
	break;
    case "muscle":
	catm="category";
	break;
  }
}
  let clname="";
  if(jivi.owner==state.player1.name)
    clname = "jivi-selected p1";
  else
    clname = "jivi-selected p2";
 
  return (<div className="col-md">
             <div><img src={"/images/" + jivi.name} alt="Image not available" width="60" height="60"/></div> 
             <div className={clname}>
               <p className="owner"> OWNER     : {jivi.owner} </p>
               <p> Jivi     : {jivi.name} </p>
               <p><span className={catf}> Fire     : {jivi.fire} </span> </p>
               <p><span className={catw}> Water    : {jivi.water} </span> </p>
               <p><span className={cate}> Electric : {jivi.electricity} </span> </p>
               <p><span className={catm}> Muscle   : {jivi.muscle} </span> </p>
             </div>
          </div>);
}

function Field(params){
  let state = params.root.state;
  let field_jivis = "";
  if(state.challenged==2)
	return (<p><a className="btn btn-primary btn-md" href="/">New Game</a></p>);
  if(state.field != null) {
      field_jivis = _.map(state.field, (jivi,ii) => {
           if (state.challenged == 1) {
              return <ShowFieldJivi key={ii} root={params.root} jivi={jivi}/>
           } else if(params.root.current_player == jivi.owner) {
              return <ShowFieldJivi root={params.root} jivi={jivi}/>
           } else if(state.challenged == 0) {
              return <FieldJivi key={ii} root={params.root} jivi={jivi}/>
           } else {
              return <ShowFieldJivi key={ii} root={params.root} jivi={jivi}/>
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
 		<p><button type="button" className="btn btn-warning" onClick={() => params.root.challengeAccepted("fire")}>Fire</button>
                   <button type="button" className="btn btn-info" onClick={() => params.root.challengeAccepted("water")}>Water</button>
                   <button type="button" className="btn btn-danger" onClick={() => params.root.challengeAccepted("electricity")}>Electricity</button>
                   <button type="button" className="btn btn-dark" onClick={() => params.root.challengeAccepted("muscle")}>Muscle</button></p>
	  </div>);
  }
  else
    return (<div></div>);
}

//Print messages according to the game state to guide the players
function Message(params) {
  let root = params.root;
  let state = params.root.state;
  let player = "";
  if(root.current_player == state.player1.name)
    player = state.player1;
  else if(root.current_player == state.player2.name)
    player = state.player2;
  else
    player = "observer";
  let in_field = _.where(state.field, {owner: player.name});
  let turn_msg = "Your turn for challenge";
  if(player != "observer"){
    if(root.state.challenged==2){
      if(player.jivis.length!=0)
        return(<h2>Congrats! You Won!</h2>);
      else
        return(<h2>You lost. Better luck next time</h2>);	
    }
    if(state.players.length < 2)
        return(<h2>Waiting for other player to join the game</h2>);
    if(state.field.length==0 || (state.field.length==1 && in_field.length==0)){
      if(player.turn)
        return (<div>Select and send your Jivi to fight<br/>{turn_msg}</div>);
      else
        return (<div> Select and send your Jivi to fight</div>);
    }
    if(state.field.length==1 && in_field.length==1)
      return (<div>Waiting for other player to send the Jivi </div>);
    if(state.field.length==2 && state.challenged==0)
      return (<div>Waiting for the challenge </div>);
    if(root.category!="")
      return(<div>Challenged on {root.category}!</div>);
 }

 if(state.challenged==2){
   if(state.player1.jivis.length!=0)
     return(<h2>{state.player1.name} won the game!</h2>);
   else
     return(<h2>{state.player2.name} won the game!</h2>);
 }
 if(state.field.length < 2)
     return(<div>Waiting for both players to send their Jivis</div>);
 if(state.field.length==2 && state.challenged==0)
     return(<div>Waiting for the challenge</div>);
 if(root.category!="")
     return(<div>Challenged on {root.category}</div>);
 return(<div></div>);
}
