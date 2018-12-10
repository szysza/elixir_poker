defmodule Poker.Card do
  @type card :: {:atom, :atom, Integer}

  @spec parse_card(String.t) :: card
  @doc """
    Function responsible for parsing card

    ## Examples

      iex> Poker.Card.parse_card("AC")
      {:A, :C, 14}

      iex> Poker.Card.parse_card("KC")
      {:K, :C, 13}

      iex> Poker.Card.parse_card("QH")
      {:Q, :H, 12}

      iex> Poker.Card.parse_card("JH")
      {:J, :H, 11}

      iex> Poker.Card.parse_card("10S")
      {:"10", :S, 10}

      iex> Poker.Card.parse_card("11S")
      {:"11", :S, 0}
  """
  def parse_card(card) do
    color = String.last(card) |> String.to_atom
    figure = String.slice(card, 0..-2)

    case Integer.parse(figure) do
      {value, _} ->
        {String.to_atom(figure), color, card_value(value)}
      :error ->
        {String.to_atom(figure), color, card_value(figure)}
    end
  end

  defp card_value("A"), do: 14
  defp card_value("K"), do: 13
  defp card_value("Q"), do: 12
  defp card_value("J"), do: 11
  defp card_value("K"), do: 13
  defp card_value(i) when is_integer(i) and i >= 2 and i <= 10, do: i
  defp card_value(_), do: 0

  @spec to_string(card) :: String.t
  @doc """
    Function that converts card into string

    ## Examples

      iex> Poker.Card.to_string({:J, :C, 11})
      "JC"
  """
  def to_string({figure, color,_}) do
    "#{figure}#{color}"
  end
end
