defmodule JiviWeb.GamesChannel do
  use JiviWeb, :channel
  alias Jivi.Game

  def join("games:" <> name, payload, socket) when name=="demo" do
    IO.puts "In demo join channel"
    games=if authorized?(payload) do
      list = Jivi.GameBackup.list_games()
      Map.keys(list)
    end
    socket = socket
    |> assign(:games, games)
    IO.inspect games
    {:ok, %{"join" => name, "games" => Game.index_view(games)}, socket}
  end


  def join("games:" <> name, payload, socket) do
    IO.puts "In games channel"
    IO.inspect name
    "player:" <> player = payload
    if authorized?(payload) do
      game = Jivi.GameBackup.load(name) || Game.new()
      game = cond do
		game.players==[] -> Map.put(game, :players, [player])
		Enum.count(game.players) < 2 && !Enum.member?(game.players, player)-> Map.put(game, :players, game.players ++ [player])
		true -> game
    	     end
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      Jivi.GameBackup.save(socket.assigns[:name], game)
      {:ok, %{"join" => name, "game" => Game.client_view(game), "player" => player}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("select", %{"jivi" => ll, "player" => ll2}, socket) do
    game = Game.select(socket.assigns[:game], ll, ll2)
#    Jivi.GameBackup.save(socket.assigns[:name], game)
#    socket = assign(socket, :game, game)
#    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
     broadcast socket, "select", game
     {:noreply, socket}
  end
  def handle_in("player", %{"name" => ll}, socket) do
    game = Game.put_player(socket.assigns[:game], ll)
#    Jivi.GameBackup.save(socket.assigns[:name], game)
#    socket = assign(socket, :game, game)
#    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
    broadcast socket, "player", game
    {:noreply, socket}
  end

  def handle_in("fight", %{"trigger" => ll}, socket) do
    IO.puts "called"
    game = Game.fight(socket.assigns[:game], ll)
    broadcast socket, "fight", %{ "game" => game }
    #Jivi.GameBackup.save(socket.assigns[:name], game)
    #socket = assign(socket, :game, game)
    {:noreply, socket}
  end

  def handle_in("challenge", %{"category" => ll}, socket) do
    game = Game.challenge(socket.assigns[:game], ll)
    #Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "challenge", %{"game" => game}
    #socket = assign(socket, :game, game)
    {:noreply, socket}
  end

  def handle_in("showjivi", %{"category" => ll}, socket) do
    game = Game.showjivi(socket.assigns[:game], ll)
    #Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "showjivi", %{"game" => game, "category" => ll}
    #socket = assign(socket, :game, game)
    {:noreply, socket}
  end

  intercept ["fight", "select","challenge", "player", "showjivi"]
  def handle_out("fight", payload, socket) do
    game = payload["game"]
    socket = assign(socket, :game, game)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "render_fight", %{"game" => game}
    {:noreply, socket}
  end

  def handle_out("challenge", %{"game" => game}, socket) do
    socket = assign(socket, :game, game)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "render_challenge", %{"game" => game}
    {:noreply, socket}
  end
  
  def handle_out("showjivi", %{"game" => game, "category"=>cat}, socket) do
    socket = assign(socket, :game, game)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "render_showjivi", %{"game" => game, "category" => cat}
    {:noreply, socket}
  end

  def handle_out("player", game, socket) do
    socket = assign(socket, :game, game)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "put_player_name", %{"game" => game}
    {:noreply, socket}
  end
  def handle_out("select", game, socket) do
    socket = assign(socket, :game, game)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "push_select", %{"game" => game}
    {:noreply, socket}
  end
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
