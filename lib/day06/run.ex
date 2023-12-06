
defmodule Day06 do
  use AdventOfCode

  def num_winning_strategies({time, record}) do
    0..time |> Enum.filter(fn x -> (time - x) * x > record end) |> Enum.count
  end

  def run() do
    race_pairs = puzzle_lines() |> FileUtil.extract_numbers() |> Enum.zip()
    new_race_pair = puzzle_lines() |> Enum.map(&Regex.replace(~r/\s/u, &1, "")) |> FileUtil.extract_numbers() |> Enum.zip()
    IO.inspect race_pairs |> Enum.map(&num_winning_strategies(&1)) |> Enum.product()
    IO.inspect new_race_pair |> Enum.map(&num_winning_strategies(&1)) |> Enum.product()
  end
end


