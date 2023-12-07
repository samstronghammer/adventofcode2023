
defmodule AdventOfCode.Day07 do
  use AdventOfCode.FileUtils

  @card_power %{"A" => 14, "K" => 13, "Q" => 12, "J" => 11, "T" => 10, "9" => 9, "8" => 8, "7" => 7, "6" => 6, "5" => 5, "4" => 4, "3" => 3, "2" => 2}
  @card_power_p2 %{@card_power | "J" => 1}
  @card_options Map.delete(@card_power, "J") |> Map.keys

  def get_card_power(card, is_p1) when is_map_key(@card_power, card) do
    map = if is_p1, do: @card_power, else: @card_power_p2
    Map.get(map, card)
  end

  def get_best_hand_power(hand) do
   @card_options |> Enum.map(fn new_card -> String.replace(hand, "J", new_card) end)
                 |> Enum.map(&get_regular_hand_power/1)
                 |> Enum.max
  end

  def get_regular_hand_power(hand) do
    hand_list = hand |> String.to_charlist
    sorted = hand_list |> Enum.map(fn x -> Enum.count(hand_list, fn c -> c === x end) end) |> Enum.sort(:desc)
    cond do
      List.first(sorted) === 5 -> 7
      List.first(sorted) === 4 -> 6
      List.first(sorted) === 3 and Enum.at(sorted, 3) === 2 -> 5
      List.first(sorted) === 3 -> 4
      Enum.at(sorted, 2) === 2 -> 3
      List.first(sorted) === 2 -> 2
      true -> 1
    end
  end

  def get_hand_power(hand, is_p1) do
    if is_p1 do
      get_regular_hand_power(hand)
    else
      get_best_hand_power(hand)
    end
  end

  def compare_hands_cardwise(h1, h2, is_p1) do
    0..4 |> Enum.reduce(nil, fn card_index, acc ->
      c1 = String.at(h1, card_index)
      c2 = String.at(h2, card_index)
      if acc === nil do
        cond do
          get_card_power(c1, is_p1) > get_card_power(c2, is_p1) -> true
          get_card_power(c1, is_p1) < get_card_power(c2, is_p1) -> false 
          true -> nil
        end
      else
        acc
      end
    end)
  end

  def compare_hands(h1, h2, is_p1) do
    cond do
      get_hand_power(h1, is_p1) > get_hand_power(h2, is_p1) -> true 
      get_hand_power(h1, is_p1) < get_hand_power(h2, is_p1) -> false 
      true -> compare_hands_cardwise(h1, h2, is_p1)
    end
  end

  def calc_winnings(lines, is_p1) do
    lines 
      |> Enum.map(&String.split(&1, " "))
      |> Enum.sort(fn hl1, hl2 -> 
        # ! to reverse order
        !compare_hands(List.first(hl1), List.first(hl2), is_p1)
      end)
      |> Enum.map(fn [_, score_string] -> String.to_integer(score_string) end)
      |> Enum.with_index
      |> Enum.map(fn {number, index} -> number * (index + 1) end)
      |> Enum.sum()
  end

  def run() do
    lines = puzzle_lines()
    IO.inspect calc_winnings(lines, true)
    IO.inspect calc_winnings(lines, false)
  end
end

