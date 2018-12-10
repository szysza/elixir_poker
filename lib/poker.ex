defmodule Poker do
  use Application

  def start(_type, _args) do
    Poker.Game.start_game
    Poker.Supervisor.start_link
  end
end
