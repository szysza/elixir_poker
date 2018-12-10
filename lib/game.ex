defmodule Poker.Game do
  def start_game() do
    if Application.get_env(:elixir_poker, :env) != :test do
      IO.puts("\r\nNEW GAME\r\n")
      hand1 = IO.gets("Player no. 1 hand: ")
      hand2 = IO.gets("Player no. 2 hand: ")

      case compare_hands(hand1, hand2) do
        {:error, error} ->
          IO.puts("\r\n#{error}")
        result ->
          IO.puts("\r\n#{result}")
        _ ->
          IO.puts("qweqw")
      end
    end
  end

  def compare_hands(hand1, hand2) do
    with parsed_hand1 <- Poker.Hand.parse_hand(hand1),
         parsed_hand2 <- Poker.Hand.parse_hand(hand2),
         {:ok, ""} <- validate_hands(parsed_hand1, parsed_hand2),
         matched_hand1 <- Poker.Hand.match_hand(parsed_hand1),
         matched_hand2 <- Poker.Hand.match_hand(parsed_hand2),
         {hand1_value, left_cards1} <- Poker.Hand.evaluate_hand(matched_hand1),
         {hand2_value, left_cards2} <- Poker.Hand.evaluate_hand(matched_hand2) do
      if hand1_value > hand2_value do
        "Player 1 won"
      else
        if hand1_value < hand2_value do
          "Player 2 won"
        else
          choose_winner(left_cards1, left_cards2)
        end
      end
    else
      err -> err
    end
  end

  def validate_hands(hand1, hand2) do
    with {:ok, _} <- Poker.Hand.validate_hand(hand1),
         {:ok, _} <- Poker.Hand.validate_hand(hand2),
         :ok <- check_hands(hand1, hand2) do
      {:ok, ""}
    else
      {:error, hand, message} ->
        {:error,
         "This hand did't pass validation: #{to_string(hand)}, beacuse: #{message}"}
      :error ->
        {:error, "Both players used the same card: #{to_string(hand1)}, #{to_string(hand2)}"}
    end
  end

  defp check_hands(hand1, hand2) do
    if Enum.any?(hand1.cards, fn card -> card in hand2.cards end) do
      :error
    else
      :ok
    end
  end

  defp choose_winner([], []) do
    "It's a tie"
  end

  defp choose_winner(hand1, hand2) do
    [h1|rest1] = hand1
    [h2|rest2] = hand2

    if h1 > h2 do
      "Player 1 won"
    else
      if h1 == h2 do
        choose_winner(rest1, rest2)
      else
        "Player 2 won"
      end
    end
  end
end
