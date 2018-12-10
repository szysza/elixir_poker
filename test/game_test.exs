defmodule Poker.GameTest do
  alias Poker.Game
  use ExUnit.Case
  doctest Poker.Game

  describe "Hand comparison" do
    test "returns an error when two occurrences of the same card appear in both players hands" do
      hand1 = "2H 2D 2S 2C 3H"
      hand2 = "4H 3D 3S 3C 3H"
      assert Game.compare_hands(hand1, hand2) == {:error, "Both players used the same card: 2H 2D 2S 2C 3H, 3D 3S 3C 3H 4H"}
    end

    test "returns information when player one won" do
      hand1 = "2H 2D 2S 2C 10H"
      hand2 = "4H 3D 3S 3C 4S"
      assert Game.compare_hands(hand1, hand2) == "Player 1 won"
    end

    test "returns information when player two won" do
      hand1 = "4H 3D 3S 3C 4S"
      hand2 = "2H 2D 2S 3H 2C"
      assert Game.compare_hands(hand1, hand2) == "Player 2 won"
    end

    test "returns information when it's a tie" do
      hand1 = "2H 2D 3H 3S 4H"
      hand2 = "2S 2C 3D 3C 4C"
      assert Game.compare_hands(hand1, hand2) == "It's a tie"
    end
  end
end
