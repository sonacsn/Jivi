defmodule Jivi.Game do
  def new do
    {p1, p2} = new_players()
    %{
      player1: p1,
      players: [],
      player2: p2,
      field: [],
      killed: [],
      challenged: 0
    }
  end

  def client_view(game) do
    %{
      player1: game.player1,
      player2: game.player2,
      field: game.field,
      killed: game.killed,
      }
  end

  def initial_jivis do
    jivis = [
      %{name: "Pikachu", fire: 60, water: 66, electricity: 72, muscle: 78, selected: false},
      %{name: "Jigglypuff", fire: 66, water: 72, electricity: 78, muscle: 84, selected: false},
      %{name: "Squirtle", fire: 72, water: 78, electricity: 84, muscle: 90, selected: false},
      %{name: "Charizard", fire: 78, water: 84, electricity: 90, muscle: 60, selected: false},
      %{name: "Snorlax", fire: 84, water: 90, electricity: 60, muscle: 66, selected: false},
      %{name: "Charmander", fire: 90, water: 60, electricity: 66, muscle: 72, selected: false},
    ]
    Enum.shuffle(jivis) |> Enum.split(3)
  end

  def change_turn(game) do
       player1 = Map.put(game.player1, :turn, !game.player1.turn)
       game = Map.put(game, :player1, player1)
       player2 = Map.put(game.player2, :turn, !game.player2.turn)
       Map.put(game, :player2, player2)
  end

  def end_game(game) do
    cond do
      length(game.player1.jivis) == 0  ->
        Map.put(game, :challenged, 2)
      length(game.player2.jivis) == 0 ->
        Map.put(game, :challenged, 2)
      true ->
        game
    end
  end

  def showjivi(game, category) do
    IO.inspect category
    Map.put(game, :challenged, 1) 
  end

  def decide_winner(jivi1, jivi2, category) when category == "fire" do
    IO.inspect "FIRE CHALLENGE"
    if(jivi1.fire > jivi2.fire) do
       {jivi1, jivi2}
    else
       {jivi2, jivi1}
    end
  end

  def decide_winner(jivi1, jivi2, category) when category == "water" do
    IO.inspect "WATER CHALLENGE"
    if(jivi1.water > jivi2.water) do
       {jivi1, jivi2}
    else
       {jivi2, jivi1}
    end
  end

  def decide_winner(jivi1, jivi2, category) when category == "electricity" do
    IO.inspect "ELECTRICITY CHALLENGE"
    if(jivi1.electricity > jivi2.electricity) do
       {jivi1, jivi2}
    else
       {jivi2, jivi1}
    end
  end

  def decide_winner(jivi1, jivi2, category) when category == "muscle" do
    IO.inspect "MUSCLE CHALLENGE"
    if(jivi1.muscle > jivi2.muscle) do
       {jivi1, jivi2}
    else
       {jivi2, jivi1}
    end
  end

  def decrease_power(jivi, category) when category == "fire" do
    Map.put(jivi, :fire, jivi.fire - 10)
  end

  def decrease_power(jivi, category) when category == "water" do
    Map.put(jivi, :water, jivi.water - 10)
  end

  def decrease_power(jivi, category) when category == "electricity" do
    Map.put(jivi, :electricity, jivi.electricity - 10)
  end

  def decrease_power(jivi, category) when category == "muscle" do
    Map.put(jivi, :muscle, jivi.muscle - 10)
  end

  def challenge(game, category) do
    game = Map.put(game, :challenged, 0)
    [jivi1, jivi2] = game.field
    jivi1 = Map.put(jivi1, :selected, false)
    jivi2 = Map.put(jivi2, :selected, false)
    {winner_jivi, loser_jivi} = decide_winner(jivi1, jivi2, category)
    winner_jivi = decrease_power(winner_jivi, category)

    game = if winner_jivi.owner == game.player1.name do
      p_jivis = game.player1.jivis ++ [winner_jivi]
      player1 = Map.put(game.player1, :jivis, p_jivis)
      Map.put(game, :player1, player1)
    else
      p_jivis = game.player2.jivis ++ [winner_jivi]
      player2 = Map.put(game.player2, :jivis, p_jivis)
      Map.put(game, :player2, player2)
    end

    game
    |> change_turn
    |> Map.put(:killed, game.killed ++ [loser_jivi])
    |> Map.put(:field, [])
    |> end_game
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
    player1 = %{turn: true, jivis: p1_jivis}
    player2 = %{turn: false, jivis: p2_jivis}
    { player1, player2 }
  end

  def put_jivi_owner(jivis, name) do
    Enum.map(jivis, fn(j) -> Map.put(j, :owner, name) end)
  end

  def put_player(game, name) do
    cond do
      !Map.has_key?(game.player1, :name) ->
        player1 = Map.put(game.player1, :name, name)
        |>Map.put(:jivis, put_jivi_owner(game.player1.jivis, name))
        Map.put(game, :player1, player1)
      !Map.has_key?(game.player2, :name) && game.player1.name != name->
        player2 = Map.put(game.player2, :name, name)
        |> Map.put(:jivis, put_jivi_owner(game.player2.jivis, name))
        Map.put(game, :player2, player2)
      true -> game
    end
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
  def fight(game, player_name) do
    ## If Player 1 has triggered fight
    if(player_name == game.player1.name) do
      player1_jivi = return_selected_jivi(game.player1.jivis)
      Map.put(game, :field, game.field ++ [player1_jivi])
      |> Map.put(:player1, %{game.player1 | jivis: game.player1.jivis -- [player1_jivi]})
    else
      player2_jivi = return_selected_jivi(game.player2.jivis)
      Map.put(game, :field, game.field ++ [player2_jivi])
      |> Map.put(:player2, %{game.player2 | jivis: game.player2.jivis -- [player2_jivi]})
    end
  end
end

