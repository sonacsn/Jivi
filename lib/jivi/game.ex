defmodule Jivi.Game do
  def new do
    {p1, p2} = new_players()
    %{
      player1: p1,
      players: [],
      player2: p2,
      field: [],
      challenged: 0
    }
  end

  def client_view(game) do
    %{
      player1: game.player1,
      player2: game.player2,
      field: game.field,
      players: game.players,
      challenged: 0
    }
  end

  def initial_jivis do
    jivis = [
      %{name: "Pikachu", fire: 100, water: 30, electricity: 500, muscle: 80, selected: false},
      %{name: "Jigglypuff", fire: 30, water: 100, electricity: 30, muscle: 20, selected: false},
      %{name: "Squirtle", fire: 80, water: 50, electricity: 50, muscle: 60, selected: false},
      %{name: "Charizard", fire: 500, water: 20, electricity: 100, muscle: 100, selected: false},
      %{name: "Snorlax", fire: 20, water: 500, electricity: 20, muscle: 500, selected: false},
      %{name: "Charmander", fire: 200, water: 60, electricity: 80, muscle: 40, selected: false},
    ]
    Enum.shuffle(jivis) |> Enum.split(3)
  end

  def change_turn(game) do
    if(game.player1.turn == true) do
       player1 = Map.put(game.player1, :turn, false)
       game = Map.put(game, :player1, player1)
       player2 = Map.put(game.player2, :turn, true)
       Map.put(game, :player2, player2)

    else
       player2 = Map.put(game.player2, :turn, false)
       game = Map.put(game, :player2, player2)
       player1 = Map.put(game.player1, :turn, true)
       Map.put(game, :player1, player1)
    end
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
    Map.put(game, :challenged, 1) 
  end

  def decide_winner(jivi1, jivi2, category) when category == "fire" do
    IO.inspect "FIRE CHALLENGE"
    if(jivi1.fire > jivi2.fire) do
       true
    else
       false
    end
  end

  def decide_winner(jivi1, jivi2, category) when category == "water" do
    IO.inspect "WATER CHALLENGE"
    if(jivi1.water > jivi2.water) do
       true
    else
       false
    end
  end

  def decide_winner(jivi1, jivi2, category) when category == "electricity" do
    IO.inspect "ELECTRICITY CHALLENGE"
    if(jivi1.electricity > jivi2.electricity) do
       true
    else
       false
    end
  end

  def decide_winner(jivi1, jivi2, category) when category == "muscle" do
    IO.inspect "MUSCLE CHALLENGE"
    if(jivi1.muscle > jivi2.muscle) do
       true
    else
       false
    end
  end

  def challenge(game, category) do
    game = Map.put(game, :challenged, 0)
    [jivi1, jivi2] = game.field
    jivi1 = Map.put(jivi1, :selected, false)
    jivi2 = Map.put(jivi2, :selected, false)
    winner = if (decide_winner(jivi1, jivi2, category)) do
      jivi2 = Map.put(jivi2, :owner, jivi1.owner)
      jivi1.owner
    else
      jivi1 = Map.put(jivi1, :owner, jivi2.owner)
      jivi2.owner
    end
    game = if winner == game.player1.name do
      p_jivis = game.player1.jivis ++ [jivi1, jivi2]
      player1 = Map.put(game.player1, :jivis, p_jivis)
      Map.put(game, :player1, player1)
    else
      p_jivis = game.player2.jivis ++ [jivi1, jivi2]
      player2 = Map.put(game.player2, :jivis, p_jivis)
      Map.put(game, :player2, player2)
    end

    game = change_turn(game)

    p = Map.put(game.player1, :ready, 0)
    game = Map.put(game, :player1, p)

    p = Map.put(game.player2, :ready, 0)
    game = Map.put(game, :player2, p)

    Map.put(game, :field, [])|> end_game
  end

  def select(game, jivi, player) do
    if game.player1.name == player["name"] do
      jivis = game.player1.jivis
      |> Enum.map(fn(j) -> if j.name==jivi["name"], do:  %{j | selected: true}, else: %{j | selected: false}
      end)
      IO.inspect "jivis"
      IO.inspect jivis
      p = Map.put(game.player1, :jivis, jivis)
      Map.put(game, :player1, p)
    else
      jivis = game.player2.jivis
      |> Enum.map(fn(j) -> if j.name==jivi["name"], do:  %{j | selected: true}, else: %{j | selected: false}
      end)
      p = Map.put(game.player2, :jivis, jivis)
      p = Map.put(p, :ready, 1)
      Map.put(game, :player2, p)
    end
  end

  def new_players do
    {p1_jivis, p2_jivis} = initial_jivis()
    #p1_jivis = Enum.map(p1_jivis, fn(j) -> Map.put(j, :owner, "P1") end)
    #p2_jivis = Enum.map(p2_jivis, fn(j) -> Map.put(j, :owner, "P2") end)
    player1 = %{turn: true, jivis: p1_jivis, ready: 0}
    player2 = %{turn: false, jivis: p2_jivis, ready: 0}
    { player1, player2 }
  end

  def put_jivi_owner(jivis, name) do
    IO.inspect "in put jivi owner"
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
  def fight(game, player_name) do
    ## If Player 1 has triggered fight
    if(player_name == game.player1.name) do
      player1_jivi = return_selected_jivi(game.player1.jivis)
      game = Map.put(game, :field, game.field ++ [player1_jivi])

      p1_old_state = game.player1
      p1_new_state = Map.put(p1_old_state, :jivis, remove_jivi_from_list(p1_old_state.jivis))
      p1_new_state = Map.put(p1_new_state, :ready, 2)
      Map.put(game, :player1, p1_new_state)

    else
      player2_jivi = return_selected_jivi(game.player2.jivis)
      game = Map.put(game, :field, game.field ++ [player2_jivi])

      p2_old_state = game.player2
      p2_new_state = Map.put(p2_old_state, :jivis, remove_jivi_from_list(p2_old_state.jivis))
      p2_new_state = Map.put(p2_new_state, :ready, 2)
      Map.put(game, :player2, p2_new_state)
    end
  end

end

