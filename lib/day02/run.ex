
defmodule AdventOfCode.Day02 do
  use AdventOfCode.FileUtils

  defmodule GameSet do
    defstruct red: 0, green: 0, blue: 0
    def from_string(s) do
      tokens = String.split(s, ", ") |> Enum.map(&(String.split(&1, " ")))
      add_balls = fn tok, acc -> 
        case tok do
          [x, "red"] -> %{acc | red: String.to_integer(x)}
          [x, "green"] -> %{acc | green: String.to_integer(x)}
          [x, "blue"] -> %{acc | blue: String.to_integer(x)}
        end
      end
      Enum.reduce(tokens, %GameSet{}, add_balls)
    end

    def possible(game_set, required) do
      game_set.red <= required.red and 
      game_set.green <= required.green and 
      game_set.blue <= required.blue
    end

    def power(game_set) do
      game_set.red * game_set.green * game_set.blue
    end

    def set_max(set_1, set_2) do
      %GameSet{
        red: max(set_1.red, set_2.red), 
        green: max(set_1.green, set_2.green), 
        blue: max(set_1.blue, set_2.blue)
      }
    end
  end

  defmodule Game do
    defstruct [:game_sets, :id]
    def from_string(s) do
      [game_str, sets_str] = String.split(s, ": ")
      [_, game_id_str] = String.split(game_str, " ")
      sets = String.split(sets_str, "; ") |> Enum.map(&GameSet.from_string/1)
      id = String.to_integer(game_id_str)
      %Game{game_sets: sets, id: id}
    end
    
    def possible(game, required) do
      game.game_sets |> Enum.all?(&GameSet.possible(&1, required))
    end

    def set_max(game) do
      Enum.reduce(game.game_sets, %GameSet{}, &GameSet.set_max/2)
    end

    def power(game) do
      GameSet.power(set_max(game))
    end
  end

  def run() do
    lines = puzzle_lines()
    required_set = %GameSet{red: 12, green: 13, blue: 14}
    sets = lines |> Enum.map(&Game.from_string/1)
    IO.inspect sets |> Enum.filter(&Game.possible(&1, required_set))
                    |> Enum.map(&(&1.id))
                    |> Enum.sum
    IO.inspect sets |> Enum.map(&Game.power/1)
                    |> Enum.sum
  end
end


