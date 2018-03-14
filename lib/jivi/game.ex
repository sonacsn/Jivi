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
      %{name: "Pikachu", fire: 100, water: 30, selected: true, played: 0},
      %{name: "Jigglypuff", fire: 30, water: 100, selected: false, played: 0},
      %{name: "Squirtle", fire: 80, water: 50, selected: false, played: 0},
      %{name: "Cherizard", fire: 500, water: 20, selected: true, played: 0},
      %{name: "Snorlax", fire: 20, water: 500, selected: false, played: 0},
      %{name: "Charmander", fire: 200, water: 60, selected: false, played: 0},
    ]
    Enum.shuffle(jivis) |> Enum.split(3)
  end

  def new_players do
    {p1_jivis, p2_jivis} = initial_jivis()
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
    player1_jivi = return_selected_jivi(game.player1.jivis)
    player2_jivi = return_selected_jivi(game.player2.jivis)
    game_update_field = Map.put(game, :field, [player1_jivi, player2_jivi])
 
    p1_old_state = game_update_field.player1
    p1_new_state = Map.put(p1_old_state, :jivis, remove_jivi_from_list(p1_old_state.jivis))
    game_update_p1jivis = Map.put(game_update_field, :player1, p1_new_state)

    p2_old_state = game_update_p1jivis.player2
    p2_new_state = Map.put(p2_old_state, :jivis, remove_jivi_from_list(p2_old_state.jivis))
    game_update_p2jivis = Map.put(game_update_p1jivis, :player2, p2_new_state)

    game_update_p2jivis

  end
end

