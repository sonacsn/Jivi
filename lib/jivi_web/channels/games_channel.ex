defmodule JiviWeb.GamesChannel do
  use JiviWeb, :channel
  alias Jivi.Game

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

  def handle_in("fight", %{"trigger" => ll}, socket) do
    game = Game.fight(socket.assigns[:game], ll)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "fight", %{ "game" => Game.client_view(game)}
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end
  def handle_in("select", %{"jivi" => ll, "player" => ll2}, socket) do
    game = Game.select(socket.assigns[:game], ll, ll2)
    IO.puts "handle fight"
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end
  def handle_in("challenge", %{"category" => ll}, socket) do
    game = Game.challenge(socket.assigns[:game], ll)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
