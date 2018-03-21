defmodule Jivi.Game do
  def new do
    {p1, p2} = new_players()
    %{
      scards: Enum.shuffle(start_board()),
      clicks: 0,
      disable_clicks: false,
      matches: 0,
      player1: p1,
      player2: p2,
      field: []
    }
  end

  def client_view(game) do
    %{
      cards: game.scards,
      clicks: game.clicks,
      disable_clicks: game.disable_clicks,
      score: score(game.matches, game.clicks),
      player1: game.player1,
      player2: game.player2,
      field: game.field
    }
  end

  def score(match, click) do
    100 - 2 * click + 4 * match
  end

  def matched?(game, position) do
    p_card = Enum.with_index(game.scards)
    |> Enum.find(fn({x,i}) -> if i != position && x[:show] , do: {i,x}  end)

    {prev_card, prev} = p_card

    if Enum.at(game.scards, position)[:value] != prev_card[:value] do
      Map.put(game, :disable_clicks, true)
    else
      game
    end
  end

  def matched(game, position) do
    p_card = Enum.with_index(game.scards)
    |> Enum.find(fn({x,i}) -> if i != position && x[:show] , do: {i,x}  end)

      {prev_card, prev} = p_card

      {cur_card, prev_card, game} = if Enum.at(game.scards, position)[:value] == prev_card[:value] do
        { Enum.at(game.scards, position) |> Map.put(:matched, true) |> Map.put(:show, false),
          Enum.at(game.scards, prev ) |> Map.put(:matched, true) |> Map.put(:show, false),
          Map.put(game, :matches, game.matches+1)
        }
      else
       { Enum.at(game.scards, position) |> Map.put(:show, false),
         Enum.at(game.scards, prev) |> Map.put(:show, false),
         Map.put(game, :disable_clicks, false)
       }
      end

      cards = game.scards
      |> Enum.with_index
      |> Enum.map(fn({ele, i}) ->
        cond do
          position == i -> cur_card
          prev == i -> prev_card
          true -> ele
        end
      end)
      Map.put(game, :scards, cards)
  end

  def flip(game, position) do
    cur_card = game.scards
    |> Enum.at(position)
    |> Map.put(:show, true)
    cards = game.scards
    |> Enum.with_index
    |> Enum.map(fn({ele, i}) -> if i==position, do: cur_card,  else:  ele  end)

    Map.put(game, :scards, cards)
    |> Map.put(:clicks, game.clicks+1)
  end

  def reset(game) do
    raise "Start a new game"
  end

  def start_board do
    cards =  [
    	%{value: "A", matched: false, show: false},
    	%{value: "G", matched: false, show: false},
    	%{value: "B", matched: false, show: false},
    	%{value: "E", matched: false, show: false},
    	%{value: "C", matched: false, show: false},
    	%{value: "H", matched: false, show: false},
    	%{value: "D", matched: false, show: false},
    	%{value: "A", matched: false, show: false},
    	%{value: "E", matched: false, show: false},
    	%{value: "C", matched: false, show: false},
    	%{value: "D", matched: false, show: false},
    	%{value: "F", matched: false, show: false},
    	%{value: "B", matched: false, show: false},
    	%{value: "G", matched: false, show: false},
    	%{value: "F", matched: false, show: false},
    	%{value: "H", matched: false, show: false},
    ]
    cards
  end

  def initial_jivis do
    jivis = [
      %{name: "Pikachu", fire: 100, water: 30, selected: false, played: 0},
      %{name: "Jigglypuff", fire: 30, water: 100, selected: false, played: 0},
      %{name: "Squirtle", fire: 80, water: 50, selected: false, played: 0},
      %{name: "Cherizard", fire: 500, water: 20, selected: false, played: 0},
      %{name: "Snorlax", fire: 20, water: 500, selected: false, played: 0},
      %{name: "Charmander", fire: 200, water: 60, selected: false, played: 0},
    ]
    Enum.shuffle(jivis) |> Enum.split(3)
  end

  def challenge(game, category) when category == "fire" do
    IO.inspect "FIRE CHALLENGE"
    [jivi1, jivi2] = game.field
    jivi1 = Map.put(jivi1, :selected, false)
    jivi2 = Map.put(jivi2, :selected, false)
    winner = if jivi1.fire > jivi2.fire do
      jivi2 = Map.put(jivi2, :owner, jivi1.owner)
      jivi1.owner
    else
      jivi1 = Map.put(jivi1, :owner, jivi2.owner)
      jivi2.owner
    end
    game = if winner == "P1" do
      p_jivis = game.player1.jivis ++ [jivi1, jivi2]
      player1 = Map.put(game.player1, :jivis, p_jivis)
      IO.inspect "p1"
      Map.put(game, :player1, player1)
    else
      p_jivis = game.player2.jivis ++ [jivi1, jivi2]
      player2 = Map.put(game.player2, :jivis, p_jivis)
      IO.inspect "p2"
      Map.put(game, :player2, player2)
    end
    Map.put(game, :field, [])
  end

  def challenge(game, category) when category == "water" do
    IO.inspect "WATER CHALLENGE"
    [jivi1, jivi2] = game.field
    jivi1 = Map.put(jivi1, :selected, false)
    jivi2 = Map.put(jivi2, :selected, false)
    winner = if jivi1.water > jivi2.water do
      jivi2 = Map.put(jivi2, :owner, jivi1.owner)
      jivi1.owner
    else
      jivi1 = Map.put(jivi1, :owner, jivi2.owner)
      jivi2.owner
    end
    game = if winner == "P1" do
      p_jivis = game.player1.jivis ++ [jivi1, jivi2]
      player1 = Map.put(game.player1, :jivis, p_jivis)
      IO.inspect "p1"
      Map.put(game, :player1, player1)
    else
      p_jivis = game.player2.jivis ++ [jivi1, jivi2]
      player2 = Map.put(game.player2, :jivis, p_jivis)
      IO.inspect "p2"
      Map.put(game, :player2, player2)
    end
    Map.put(game, :field, [])
  end

  def challenge(game, category) when category == "electricity" do
    IO.inspect "ELECTRICITY CHALLENGE"
    [jivi1, jivi2] = game.field
    jivi1 = Map.put(jivi1, :selected, false)
    jivi2 = Map.put(jivi2, :selected, false)
    winner = if jivi1.electricity > jivi2.electricity do
      jivi2 = Map.put(jivi2, :owner, jivi1.owner)
      jivi1.owner
    else
      jivi1 = Map.put(jivi1, :owner, jivi2.owner)
      jivi2.owner
    end
    game = if winner == "P1" do
      p_jivis = game.player1.jivis ++ [jivi1, jivi2]
      player1 = Map.put(game.player1, :jivis, p_jivis)
      IO.inspect "p1"
      Map.put(game, :player1, player1)
    else
      p_jivis = game.player2.jivis ++ [jivi1, jivi2]
      player2 = Map.put(game.player2, :jivis, p_jivis)
      IO.inspect "p2"
      Map.put(game, :player2, player2)
    end
    Map.put(game, :field, [])
  end

  def challenge(game, category) when category == "muscle" do
    IO.inspect "MUSCLE CHALLENGE"
    [jivi1, jivi2] = game.field
    jivi1 = Map.put(jivi1, :selected, false)
    jivi2 = Map.put(jivi2, :selected, false)
    winner = if jivi1.muscle > jivi2.muscle do
      jivi2 = Map.put(jivi2, :owner, jivi1.owner)
      jivi1.owner
    else
      jivi1 = Map.put(jivi1, :owner, jivi2.owner)
      jivi2.owner
    end
    game = if winner == "P1" do
      p_jivis = game.player1.jivis ++ [jivi1, jivi2]
      player1 = Map.put(game.player1, :jivis, p_jivis)
      IO.inspect "p1"
      Map.put(game, :player1, player1)
    else
      p_jivis = game.player2.jivis ++ [jivi1, jivi2]
      player2 = Map.put(game.player2, :jivis, p_jivis)
      IO.inspect "p2"
      Map.put(game, :player2, player2)
    end
    Map.put(game, :field, [])
  end

  def select(game, jivi, player) do
    if game.player1.name == player["name"] do
      jivis = game.player1.jivis
      |> Enum.map(fn(j) -> if j.name==jivi["name"], do:  %{j | selected: true}, else: %{j | selected: false}
      end)
      p = Map.put(game.player1, :jivis, jivis)
      Map.put(game, :player1, p)
    else
      jivis = game.player2.jivis
      |> Enum.map(fn(j) -> if j.name==jivi["name"], do:  %{j | selected: true}, else: %{j | selected: false}
      end)
      p = Map.put(game.player2, :jivis, jivis)
      Map.put(game, :player2, p)
    end
  end

  def new_players do
    {p1_jivis, p2_jivis} = initial_jivis()
    p1_jivis = Enum.map(p1_jivis, fn(j) -> Map.put(j, :owner, "P1") end)
    p2_jivis = Enum.map(p2_jivis, fn(j) -> Map.put(j, :owner, "P2") end)
    player1 = %{name: "P1", turn: true, jivis: p1_jivis }
    player2 = %{name: "P2", turn: false, jivis: p2_jivis}
    { player1, player2 }
  end

  ## Accept a list of jivis
  ## Return a list of jivis which doesn't contain any slected jivi
  def remove_jivi_from_list(jivis) do
    Enum.filter(jivis, fn(jivi) ->
	Map.fetch!(jivi, :selected) == false
    end)
  end
  
  ## Accepts a list of jivis
  ## Returns the first jivi whose selected filed is set to true
  def return_selected_jivi(jivis) do
    Enum.find(jivis, fn(jivi) ->
      if(Map.fetch!(jivi, :selected) == true) do
         jivi
      end
    end)
  end

  ## Accepts the game state and trigger which is the challenge type
  ## Returns a game state where selected Jivis are removed from player list and are placed in field
  def fight(game, _trigger) do
   
    ## If Player 1 has triggered fight
    if(_trigger == 1) do
      player1_jivi = return_selected_jivi(game.player1.jivis)
      game = Map.put(game, :field, game.field ++ [player1_jivi])

      p1_old_state = game.player1
      p1_new_state = Map.put(p1_old_state, :jivis, remove_jivi_from_list(p1_old_state.jivis))
      Map.put(game, :player1, p1_new_state)

    else
      player2_jivi = return_selected_jivi(game.player2.jivis)
      game = Map.put(game, :field, game.field ++ [player2_jivi])

      p2_old_state = game.player2
      p2_new_state = Map.put(p2_old_state, :jivis, remove_jivi_from_list(p2_old_state.jivis))
      Map.put(game, :player2, p2_new_state)
    end
  end

end

