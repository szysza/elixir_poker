defmodule Poker.HandTest do
  alias Poker.Hand
  use ExUnit.Case
  doctest Poker.Hand

  describe "Hand parsing" do
    test "trims addional new lines" do
      hand = %Poker.Hand{
        cards: [
          {:"9", :S, 9},
          {:J, :S, 11},
          {:J, :C, 11},
          {:K, :D, 13},
          {:A, :H, 14}
        ]
      }

      assert Poker.Hand.parse_hand("AH KD JS JC 9S\n") == hand
    end

    test "returns an empty hand when no cards passed to parse" do
      hand = %Poker.Hand{cards: []}

      assert Poker.Hand.parse_hand("") == hand
    end

    test "returns an empty hand empty line passed to parse" do
      hand = %Poker.Hand{cards: []}

      assert Poker.Hand.parse_hand("\n") == hand
    end
  end

  describe "Hand validations" do
    test "returns an error when there is too much cards in hand" do
      hand = %Poker.Hand{
        cards: [
          {:A, :H, 14},
          {:K, :D, 13},
          {:J, :S, 11},
          {:J, :C, 11},
          {:J, :H, 11},
          {"9", :H, 9}
        ]
      }

      assert Hand.validate_hand(hand) == {:error, hand, "Size of hand is 6"}
    end

    test "returns an error when there is not enough cards in hand1" do
      hand = Poker.Hand.parse_hand("AH KD JS JC 9S")
      assert Hand.validate_hand(hand) == {:ok, hand}
    end

    test "returns an error when there is not enough cards in hand" do
      hand = %Poker.Hand{cards: [{:A, :H, 14}, {:K, :D, 13}, {:J, :S, 11}, {:J, :C, 11}]}
      assert Hand.validate_hand(hand) == {:error, hand, "Size of hand is 4"}
    end

    test "returns an error when a card occurs multiple times" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :D, 13}, {:J, :S, 11}, {:J, :C, 11}, {:J, :C, 11}]
      }

      assert Hand.validate_hand(hand) == {:error, hand, "Hand contains not unique cards #{hand}"}
    end

    test "returns an error when a card is not included in deck" do
      hand = %Poker.Hand{
        cards: [{:A, :A, 14}, {:K, :D, 13}, {:J, :S, 11}, {:J, :C, 11}, {:J, :D, 11}]
      }

      assert Hand.validate_hand(hand) ==
               {:error, hand, "Not all cards from hand are valid cards #{to_string(hand)}"}
    end
  end

  describe "Match hand" do
    test "match hand with royal_flush" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :H, 13}, {:Q, :H, 12}, {:J, :H, 11}, {"10", :H, 10}]
      }

      assert Hand.match_hand(hand) == {:royal_flush, [14], []}
    end

    test "match hand with straight flush" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:Q, :H, 12}, {:J, :H, 11}, {"10", :H, 10}, {"9", :H, 9}]
      }

      assert Hand.match_hand(hand) == {:straight_flush, [13], []}
    end

    test "match hand with four of a kind #1" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:A, :D, 14}, {:A, :S, 14}, {:A, :C, 14}, {"10", :H, 10}]
      }

      assert Hand.match_hand(hand) == {:four_of_a_kind, [14], [10]}
    end

    test "match hand with four of a kind #2" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:Q, :D, 12}, {:Q, :S, 12}, {:Q, :C, 12}, {:Q, :H, 12}]
      }

      assert Hand.match_hand(hand) == {:four_of_a_kind, [12], [13]}
    end

    test "match hand with full house #1" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:K, :D, 13}, {:K, :S, 13}, {:Q, :C, 12}, {:Q, :H, 12}]
      }

      assert Hand.match_hand(hand) == {:full_house, [13, 12], []}
    end

    test "match hand with full house #2" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:K, :D, 13}, {:Q, :S, 12}, {:Q, :C, 12}, {:Q, :H, 12}]
      }

      assert Hand.match_hand(hand) == {:full_house, [12, 13], []}
    end

    test "match and with flush" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:J, :H, 12}, {"10", :H, 10}, {"6", :H, 6}, {"3", :H, 3}]
      }

      assert Hand.match_hand(hand) == {:flush, [13], []}
    end

    test "match hand with straight" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:Q, :D, 12}, {:J, :H, 11}, {"10", :H, 10}, {"9", :H, 9}]
      }

      assert Hand.match_hand(hand) == {:straight, [13], []}
    end

    test "match hand with three of a kind #1" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:K, :D, 13}, {:K, :S, 13}, {:Q, :C, 12}, {:J, :H, 11}]
      }

      assert Hand.match_hand(hand) == {:three_of_a_kind, [13], [12, 11]}
    end

    test "match hand with three of a kind #2" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:Q, :D, 12}, {:Q, :S, 12}, {:Q, :C, 12}, {:J, :H, 11}]
      }

      assert Hand.match_hand(hand) == {:three_of_a_kind, [12], [14, 11]}
    end

    test "match hand with three of a kind #3" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :D, 13}, {:Q, :S, 12}, {:Q, :C, 12}, {:Q, :H, 12}]
      }

      assert Hand.match_hand(hand) == {:three_of_a_kind, [12], [14, 13]}
    end

    test "match hand with two pairs #1" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:A, :D, 14}, {:Q, :S, 12}, {:Q, :C, 12}, {:J, :H, 11}]
      }

      assert Hand.match_hand(hand) == {:two_pairs, [14, 12], [11]}
    end

    test "match hand with two pairs #2" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:A, :D, 14}, {:K, :S, 13}, {:Q, :C, 12}, {:Q, :H, 12}]
      }

      assert Hand.match_hand(hand) == {:two_pairs, [14, 12], [13]}
    end

    test "match hand with two pairs #3" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :D, 13}, {:K, :S, 13}, {:Q, :C, 12}, {:Q, :H, 12}]
      }

      assert Hand.match_hand(hand) == {:two_pairs, [13, 12], [14]}
    end

    test "match hand with pair #1" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:K, :D, 13}, {:Q, :S, 12}, {:J, :C, 11}, {"5", :H, 5}]
      }

      assert Hand.match_hand(hand) == {:pair, [13], [12, 11, 5]}
    end

    test "match hand with pair #2" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :D, 13}, {:K, :S, 13}, {:Q, :C, 12}, {:J, :H, 11}]
      }

      assert Hand.match_hand(hand) == {:pair, [13], [14, 12, 11]}
    end

    test "match hand with pair #3" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :D, 13}, {:Q, :S, 12}, {:Q, :C, 12}, {:J, :H, 11}]
      }

      assert Hand.match_hand(hand) == {:pair, [12], [14, 13, 11]}
    end

    test "match hand with pair #4" do
      hand = %Poker.Hand{
        cards: [{:A, :H, 14}, {:K, :D, 13}, {:Q, :S, 12}, {:J, :C, 11}, {:J, :H, 11}]
      }

      assert Hand.match_hand(hand) == {:pair, [11], [14, 13, 12]}
    end

    test "match hand with high card" do
      hand = %Poker.Hand{
        cards: [{:K, :H, 13}, {:Q, :D, 12}, {:J, :S, 11}, {"9", :C, 9}, {"6", :H, 5}]
      }

      assert Hand.match_hand(hand) == {:high_card, [13], [12, 11, 9, 5]}
    end
  end

  describe "Evaluate hand" do
    test "evaluate royal flush" do
      matched_hand = {:royal_flush, [14], []}
      assert Hand.evaluate_hand(matched_hand) == {9014, []}
    end

    test "evaluate straight flush" do
      matched_hand = {:straight_flush, [13], []}
      assert Hand.evaluate_hand(matched_hand) == {8013, []}
    end

    test "evaluate straight four of a kind" do
      matched_hand = {:four_of_a_kind, [12], [13]}
      assert Hand.evaluate_hand(matched_hand) == {7012, [13]}
    end

    test "evaluate full house" do
      matched_hand = {:full_house, [12, 13], []}
      assert Hand.evaluate_hand(matched_hand) == {6025, []}
    end

    test "evaluate flush" do
      matched_hand = {:flush, [13], []}
      assert Hand.evaluate_hand(matched_hand) == {5013, []}
    end

    test "evaluate straight" do
      matched_hand = {:straight, [13], []}
      assert Hand.evaluate_hand(matched_hand) == {4013, []}
    end

    test "evaluate three of a kind" do
      matched_hand = {:three_of_a_kind, [12], [14, 13]}
      assert Hand.evaluate_hand(matched_hand) == {3012, [14, 13]}
    end

    test "evaluate two pairs" do
      matched_hand = {:two_pairs, [14, 12], [13]}
      assert Hand.evaluate_hand(matched_hand) == {2026, [13]}
    end

    test "evaluate one pair" do
      matched_hand = {:pair, [13], [14, 12, 11]}
      assert Hand.evaluate_hand(matched_hand) == {1013, [14, 12, 11]}
    end

    test "evaluate high card" do
      matched_hand = {:high_card, [13], [12, 11, 9, 5]}
      assert Hand.evaluate_hand(matched_hand) == {13, [12, 11, 9, 5]}
    end
  end
end
