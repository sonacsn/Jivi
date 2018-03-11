defmodule Jivi.Game do
  def new do
    %{
      scards: Enum.shuffle(start_board()),
      clicks: 0,
      disable_clicks: false,
      matches: 0
    }
  end

  def client_view(game) do
    %{
      cards: game.scards,
      clicks: game.clicks,
      disable_clicks: game.disable_clicks,
      score: score(game.matches, game.clicks)
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
end

