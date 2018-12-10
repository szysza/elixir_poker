defmodule Poker.Deck do
  @spec generate_deck :: [String.t()]
  @doc """
    Function for generating poker deck
  """
  def generate_deck do
    colors = ["H", "D", "S", "C"]
    high_values = ["J", "Q", "K", "A"]

    low_values =
      Enum.to_list(2..10)
      |> Enum.map(&to_string(&1))

    values = low_values ++ high_values
    for value <- values, color <- colors, do: value <> color
  end
end
