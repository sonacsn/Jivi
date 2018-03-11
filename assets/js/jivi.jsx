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
		score: 100};

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

  render() {
    return (
      <div className="container">
        <div className="row">
    	  <div className="col-sm">
	    <div className="container" >
              <div className="row">
                <div className="col-md"><Card root={this} pos={0}/></div>
                <div className="col-md"><Card root={this} pos={1}/></div>
                <div className="col-md"><Card root={this} pos={2}/></div>
                <div className="col-md"><Card root={this} pos={3}/></div>
              </div>
	      <div className="row">
                <div className="col-md"><Card root={this} pos={4}/></div>
                <div className="col-md"><Card root={this} pos={5}/></div>
                <div className="col-md"><Card root={this} pos={6}/></div>
                <div className="col-md"><Card root={this} pos={7}/></div>
              </div> 
              <div className="row">
                <div className="col-md"><Card root={this} pos={8}/></div>
                <div className="col-md"><Card root={this} pos={9}/></div>
                <div className="col-md"><Card root={this} pos={10}/></div>
                <div className="col-md"><Card root={this} pos={11}/></div>
              </div>
              <div className="row">
                <div className="col-md"><Card root={this} pos={12}/></div>
                <div className="col-md"><Card root={this} pos={13}/></div>
                <div className="col-md"><Card root={this} pos={14}/></div>
                <div className="col-md"><Card root={this} pos={15}/></div>
              </div>
              <div className="row">
          	<div className="col-md-6">
            	  <b>Score: </b>
            	  <Score root={this} />
	  	</div>
	    	<div className="col-md-6">  
	    	  <Button onClick={() => this.reset()}>Reset</Button>
          	</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
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

