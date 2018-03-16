defmodule JiviWeb.GamesChannel do
  use JiviWeb, :channel
  alias Jivi.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Jivi.GameBackup.load(name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("flip", %{"position" => ll}, socket) do
    game = Game.flip(socket.assigns[:game], ll)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("matched", %{"position" => ll}, socket) do
    game = Game.matched(socket.assigns[:game], ll)
    Jivi.GameBackup.save(socket.assigns[:name], game)    
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("matched?", %{"position" => ll}, socket) do
    game = Game.matched?(socket.assigns[:game], ll)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("reset", %{}, socket) do
    game = Game.new()
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("fight", %{"trigger" => ll}, socket) do
    game = Game.fight(socket.assigns[:game], ll)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end
  def handle_in("select", %{"jivi" => ll, "player" => ll2}, socket) do
    game = Game.select(socket.assigns[:game], ll, ll2)
    Jivi.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
