import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_demo(root) {
  ReactDOM.render(<Demo side={0}/>, root);
}

function startBoard(){
  let cards =  [
    	{value: "A", matched: false, show: false},
    	{value: 'G', matched: false, show: false},
    	{value: 'B', matched: false, show: false},
    	{value: 'E', matched: false, show: false},
    	{value: 'C', matched: false, show: false},
    	{value: 'H', matched: false, show: false},
    	{value: 'D', matched: false, show: false},
    	{value: 'A', matched: false, show: false},
    	{value: 'E', matched: false, show: false},
    	{value: 'C', matched: false, show: false},
    	{value: 'D', matched: false, show: false},
    	{value: 'F', matched: false, show: false},
    	{value: 'B', matched: false, show: false},
    	{value: 'G', matched: false, show: false},
    	{value: 'F', matched: false, show: false},
    	{value: 'H', matched: false, show: false},

  ];
  cards = _.shuffle(cards);
  return cards;
}

class Demo extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      cards: startBoard(),
      matches: 0,
      clicks: 0,
      previous_card: null,
      disable_click: false
    };
  }

  flip(pos) {
    this.state.clicks += 1;
    let curr_card = this.state.cards[pos];
    curr_card.show = true;
    this.state.cards[pos] = curr_card;

    this.setState({cards: this.state.cards, clicks: this.state.clicks});
    if (this.state.clicks % 2 == 0) {
      let prev = this.state.previous_card;
      let prev_card = this.state.cards[prev];

      if (prev_card.value == curr_card.value) {
        this.matchCards(pos, prev);
      } else {
        this.unmatchCards(pos, prev);
      }
    } else {
      this.setState({previous_card: pos});
    }

  }

  matchCards(pos, prev) {
    setTimeout(() => {
      this.state.cards[prev].matched = true;
      this.state.cards[pos].matched = true;
      this.setState({
        cards: this.state.cards,
        previous_card: null,
        disable_click: false,
        matches: this.state.matches + 1
      })
    }, 300);
  }

  unmatchCards(pos, prev) {
    this.state.disable_click = true;
    setTimeout(() => {
      this.state.cards[pos].show = false;
      this.state.cards[prev].show = false;
      this.setState({cards: this.state.cards, previous_card: null, disable_click: false});
    }, 1000);
  }

  reset() {
    this.setState({cards: startBoard(), matches: 0, clicks: 0, previous_card: null, disable_click: false});
  }

  render() {
    return (<div className="container">
      <div className="row">
        <div className="col-sm">
          <div className="container">
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
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-md-6">
          <b>Score:
          </b>
          <Score root={this}/>
        </div>
        <div className="col-md-6">
          <Button onClick={() => this.reset()}>Reset</Button>
        </div>
      </div>
    </div>);

  }

}

function Card(params) {
  let root = params.root;
  let pos = params.pos;
  let current_card = root.state.cards[pos];

  if (current_card.matched) {
    return <div className="card-matched"></div>;
  }
  if (current_card.show) {
    return <div className="card-front">{current_card.value}</div>;
  } else {
    if (root.state.disable_click) {
      return <div className="card-back"></div>;
    } else {
      return <div className="card-back" onClick={() => root.flip(pos)}></div>;
    }
  }
}

function Score(params) {
  let root = params.root;
  let score = 100 - 2 * (root.state.clicks) + 4 * (root.state.matches);
  return <b>{score}</b>;
}

