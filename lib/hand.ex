defmodule Poker.Hand do
  @type card :: {:atom, :atom, Integer}
  @type matched_hand :: {:atom, list(Integer), list(Integer)}

  defstruct [:cards]

  # @spec parse_hand(String.t()) :: %Poker.Hand{}
  # @doc """
  #   Function responsible for parsing user input
  # """
  def parse_hand("") do
    %Poker.Hand{cards: []}
  end

  def parse_hand("\n") do
    %Poker.Hand{cards: []}
  end

  def parse_hand(input) do
    cards =
      input
      |> String.trim("\r\n")
      |> String.trim("\n")
      |> String.upcase()
      |> String.split(" ")
      |> Enum.map(&Poker.Card.parse_card(&1))
      |> Enum.sort(&(elem(&1, 2) <= elem(&2, 2)))

    %Poker.Hand{cards: cards}
  end

  @spec validate_hand(%Poker.Hand{}) :: tuple
  @doc """
    Function responsible for checking hand correctness
  """
  def validate_hand(hand) do
    with {:ok, ""} <- validate_hand_length(hand),
         {:ok, ""} <- validate_number_of_card_occurrences(hand),
         {:ok, ""} <- validate_deck_inclusion(hand) do
      {:ok, hand}
    else
      {:error, :err_wrong_number_of_cards} ->
        {:error, hand , "Size of hand is #{length(hand.cards)}"}
      {:error, :err_not_unique_hand} ->
        {:error, hand, "Hand contains not unique cards #{to_string(hand)}"}
      {:error, :err_card_not_included_in_deck} ->
        {:error, hand, "Not all cards from hand are valid cards #{to_string(hand)}"}
    end
  end

  # Function responsible for validating number of cards in hand
  defp validate_hand_length(%Poker.Hand{cards: cards}) do
    case length(cards) do
      5 -> {:ok, ""}
      _ -> {:error, :err_wrong_number_of_cards}
    end
  end

  # Function responsible for validating single occurrence of each card
  defp validate_number_of_card_occurrences(%Poker.Hand{cards: cards}) do
    norm_hand = Enum.map(cards, fn card -> Poker.Card.to_string(card) end)

    if length(Enum.uniq(norm_hand)) == length(cards) do
      {:ok, ""}
    else
      {:error, :err_not_unique_hand}
    end
  end

  # Function responsible for validating cards inclusion in deck
  defp validate_deck_inclusion(%Poker.Hand{cards: cards}) do
    deck = Poker.Deck.generate_deck()

    cards_list = Enum.map(cards, fn card -> Poker.Card.to_string(card) end)

    if Enum.all?(cards_list, fn card -> card in deck end) do
      {:ok, ""}
    else
      {:error, :err_card_not_included_in_deck}
    end
  end

  @spec match_hand(%Poker.Hand{}) :: matched_hand
  @doc """
    Function responsible for rating hand
  """
  def match_hand(%Poker.Hand{cards: cards}) do
    case cards do
      [{_, _, a}, {_, _, a}, {_, _, a}, {_, _, a}, {_, _, b}] ->
        {:four_of_a_kind, [a], [b]}

      [{_, _, a}, {_, _, b}, {_, _, b}, {_, _, b}, {_, _, b}] ->
        {:four_of_a_kind, [b], [a]}

      [{_, _, a}, {_, _, a}, {_, _, a}, {_, _, b}, {_, _, b}] ->
        {:full_house, [a, b], []}

      [{_, _, a}, {_, _, a}, {_, _, b}, {_, _, b}, {_, _, b}] ->
        {:full_house, [b, a], []}

      [{_, _, a}, {_, _, a}, {_, _, a}, {_, _, b}, {_, _, c}] ->
        {:three_of_a_kind, [a], [b, c]}

      [{_, _, a}, {_, _, b}, {_, _, b}, {_, _, b}, {_, _, c}] ->
        {:three_of_a_kind, [b], [a, c]}

      [{_, _, a}, {_, _, b}, {_, _, c}, {_, _, c}, {_, _, c}] ->
        {:three_of_a_kind, [c], [a, b]}

      [{_, _, a}, {_, _, a}, {_, _, b}, {_, _, b}, {_, _, c}] ->
        {:two_pairs, [a, b], [c]}

      [{_, _, a}, {_, _, b}, {_, _, b}, {_, _, c}, {_, _, c}] ->
        {:two_pairs, [b, c], [a]}

      [{_, _, a}, {_, _, a}, {_, _, b}, {_, _, c}, {_, _, c}] ->
        {:two_pairs, [a, c], [b]}

      [{_, _, a}, {_, _, a}, {_, _, b}, {_, _, c}, {_, _, d}] ->
        {:pair, [a], [b, c, d]}

      [{_, _, a}, {_, _, b}, {_, _, b}, {_, _, c}, {_, _, d}] ->
        {:pair, [b], [a, c, d]}

      [{_, _, a}, {_, _, b}, {_, _, c}, {_, _, c}, {_, _, d}] ->
        {:pair, [c], [a, b, d]}

      [{_, _, a}, {_, _, b}, {_, _, c}, {_, _, d}, {_, _, d}] ->
        {:pair, [d], [a, b, c]}

      [{_, c1, v1}, {_, c1, v2}, {_, c1, v3}, {_, c1, v4}, {_, c1, v5}] ->
        if consequestive?([v1, v2, v3, v4, v5]) do
          if v1 == 14, do: {:royal_flush, [v1], []}, else: {:straight_flush, [v1], []}
        else
          {:flush, [v1], []}
        end

      [{_, _c1, v1}, {_, _c2, v2}, {_, _c3, v3}, {_, _c4, v4}, {_, _c5, v5}] ->
        if consequestive?([v1, v2, v3, v4, v5]) do
          {:straight, [v1], []}
        else
          {:high_card, [v1], [v2, v3, v4, v5]}
        end
    end
  end

  defp consequestive?([value1 | values]) do
    case values do
      [] ->
        true

      [h | _] ->
        if value1 - h == 1 do
          consequestive?(values)
        else
          false
        end
    end
  end

  @spec evaluate_hand(matched_hand) :: tuple
  @doc """
    Function responsible for evaluating cards combinations
  """
  def evaluate_hand(hand) do
    {_, values, _} = hand
    sum_of_hand = Enum.sum(values)

    case hand do
      {:royal_flush, _, cards} -> {9000 + sum_of_hand, cards}
      {:straight_flush, _, cards} -> {8000 + sum_of_hand, cards}
      {:four_of_a_kind, _, cards} -> {7000 + sum_of_hand, cards}
      {:full_house, _, cards} -> {6000 + sum_of_hand, cards}
      {:flush, _, cards} -> {5000 + sum_of_hand, cards}
      {:straight, _, cards} -> {4000 + sum_of_hand, cards}
      {:three_of_a_kind, _, cards} -> {3000 + sum_of_hand, cards}
      {:two_pairs, _, cards} -> {2000 + sum_of_hand, cards}
      {:pair, _, cards} -> {1000 + sum_of_hand, cards}
      {:high_card, _, cards} -> {sum_of_hand, cards}
      _ -> {0, []}
    end
  end

  defimpl String.Chars, for: Poker.Hand do
    def to_string(hand) do
      hand.cards
      |> Enum.map(fn card -> Poker.Card.to_string(card) end)
      |> Enum.join(" ")
    end
  end
end
