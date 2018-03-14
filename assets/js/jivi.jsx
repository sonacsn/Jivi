import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<MemoryGame channel={channel} />, root);
}

class MemoryGame extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.state = {
		cards: [], matches: 0,
		clicks: 0,
		previous_card: null, 
		disable_clicks: false, 
		score: 100, 
                player1: null,
                player2: null,
		field: null};

    this.channel.join()
        .receive("ok", this.gotView.bind(this))
        .receive("error", resp => { console.log("Unable to join", resp) });
  }

  gotView(view) {
    console.log("New view", view);
    this.setState(view.game);
  }

  reset(){
    this.channel.push("reset")
		.receive("ok", this.gotView.bind(this));
  }

  flipBack(view, pos){
    this.gotView(view);
    if(this.state.disable_clicks){
      setTimeout(() => {
		this.channel.push("matched", {position: pos})
			    .receive("ok", this.gotView.bind(this));}, 1000);
    }
    else{
      this.channel.push("matched", {position: pos})
		  .receive("ok", this.gotView.bind(this));
    }
  }

  matchCards(view, pos) {
    this.gotView(view);
    if(this.state.clicks % 2 == 0){
     this.channel.push("matched?", {position: pos})
                                 .receive("ok", resp => {this.flipBack(resp, pos)});
    }
  }

  flip(pos) {
    this.channel.push("flip", { position: pos })
        .receive("ok", resp => {this.matchCards(resp, pos)});
  }

  fight(trigger) {
     this.channel.push("fight", { trigger: trigger })
         .receive("ok", this.gotView.bind(this));
  }

  render() {
    let player1_jivis = "";
    let player2_jivis = "";  
    let field_jivis = "";
    if(this.state.player1 != null) {
      player1_jivis = _.map(this.state.player1.jivis, (jivi) => {
        return <Jivi jivi={jivi} root={this} />;
	  });
    }
    if(this.state.player2 != null) {
      player2_jivis = _.map(this.state.player2.jivis, (jivi) => {
        return <Jivi jivi={jivi} root={this} />;
          });
    }

    if(this.state.field != null) {
      field_jivis = _.map(this.state.field, (jivi) => {
        return <Jivi jivi={jivi} root={this} />;
          });
    }


    if(this.state.player1==null){ player1_jivis=""; }
    console.log("jivi list");
    
    return (
      <div className="container">
        <div className="row">
          { player2_jivis }
        </div>
        <div className="row">
          <div className="col-md-6">
            <h3>Player 2</h3>
          </div>
        </div>
        <div className="row">
	  { field_jivis }
          <button type="button" onClick={() => this.fight(0)}>Fight</button>
        </div>
        <div className="row">
          <div className="col-md-6">
            <h3>Field</h3>
          </div>
        </div>
        <div className="row">
          { player1_jivis }
        </div>
        <div className="row">
          <div className="col-md-6">
            <h3>Player 1</h3>
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
  if(state.player1==null) {
    return (<div><p>Loading---</p></div>);
  }
  return (<div className="col-md"><div className="card-back"></div></div>);
}

function Card(params) {
  let state = params.root.state;
  let pos = params.pos;
  let root = params.root;
  let current_card = state.cards[pos];
  if(current_card==null){
    return (<div><p>Loading...</p></div>);
  }
  if(current_card.matched){
    return <div className="card-matched"></div>;
  }
  if(current_card.show){
    return <div className="card-front">{current_card.value}</div>;
  }
  else {
    if(state.disable_clicks){
      return <div className="card-back"></div>;
    }
    else{
      return <div className="card-back" onClick={() => root.flip(pos)}></div>;
    }
  }
}

function Score(params){
  let state = params.root.state;
  return <b>{ state.score } </b>;
}

