
defmodule AdventOfCode.Day14 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.CycleUtils
  alias AdventOfCode.FileUtils

  def rocks_load(round_rocks, max_row) do
    round_rocks |> Enum.map(fn {row, _col} -> max_row + 1 - row end) |> Enum.sum
  end

  def find_next_pos({round_rocks, square_rocks, {delta_row, delta_col}, {max_row, max_col}} = metadata, {curr_row, curr_col}, num_rocks_seen) do
    next_pos = {curr_row + delta_row, curr_col + delta_col}
    {next_row, next_col} = next_pos
    outside_range = next_row > max_row or next_row < 0 or next_col > max_col or next_col < 0 
    case {MapSet.member?(round_rocks, next_pos), MapSet.member?(square_rocks, next_pos) or outside_range} do
      {true, true} -> raise "Impossible"
      {true, false} -> find_next_pos(metadata, next_pos, num_rocks_seen + 1)
      {false, true} -> {curr_row - delta_row * num_rocks_seen, curr_col - delta_col * num_rocks_seen}
      {false, false} -> find_next_pos(metadata, next_pos, num_rocks_seen)
    end
  end  

  def tilt_rocks(round_rocks, square_rocks, delta_pos, max_pos) do
    round_rocks |> Enum.map(fn round_rock -> 
      find_next_pos({round_rocks, square_rocks, delta_pos, max_pos}, round_rock, 0)
    end) |> MapSet.new
  end
  
  def cycle_rocks(round_rocks, square_rocks, max_pos) do
    round_rocks |> tilt_rocks(square_rocks, {-1, 0}, max_pos)
                |> tilt_rocks(square_rocks, {0, -1}, max_pos)
                |> tilt_rocks(square_rocks, {1, 0}, max_pos)
                |> tilt_rocks(square_rocks, {0, 1}, max_pos)
  end

  def run() do
    grid = puzzle_lines() |> FileUtils.lines_to_grid
    round_rocks = grid |> Enum.filter(fn {_point, char} -> char === "O" end)
                       |> Enum.map(fn {point, _char} -> point end)
                       |> MapSet.new
    square_rocks = grid |> Enum.filter(fn {_point, char} -> char === "#" end)
                        |> Enum.map(fn {point, _char} -> point end)
                        |> MapSet.new
    {max_row, max_col} = FileUtils.grid_maximum(grid)
    north_round_rocks = tilt_rocks(round_rocks, square_rocks, {-1, 0}, {max_row, max_col})
    IO.inspect rocks_load(north_round_rocks, max_row)
    
    stream = Stream.iterate({rocks_load(round_rocks, max_row), round_rocks}, fn {_load, rocks} -> 
      next_round_rocks = cycle_rocks(rocks, square_rocks, {max_row, max_col})
      {rocks_load(next_round_rocks, max_row), next_round_rocks}
    end)

    IO.inspect CycleUtils.calc_big_cycle_index(stream, 1_000_000_000)
  end
end


