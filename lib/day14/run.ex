
defmodule AdventOfCode.Day14 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  def tick_direction(grid, {delta_row, delta_col}) do
    grid |> Enum.map(fn {{row, col}, char} = entry -> 
      next_pos = {row + delta_row, col + delta_col}
      prev_pos = {row - delta_row, col - delta_col}
      case {char, Map.get(grid, next_pos), Map.get(grid, prev_pos)} do
        {"#", _, _} -> entry 
        {".", _, "O"} -> {prev_pos, char}
        {".", _, _} -> entry
        {"O", ".", _} -> {next_pos, char}
        {"O", _, _} -> entry
      end
    end) |> Map.new
  end

  def grid_load(grid) do
    {row_max, _col_max} = FileUtils.grid_maximum(grid)
    grid |> Enum.map(fn {{row, _col}, char} -> 
      case char do
        "O" -> row_max + 1 - row
        _ -> 0
      end
    end) |> Enum.sum
  end 

  def tilt_grid(grid, direction) do
    next_grid = tick_direction(grid, direction)
    if Map.equal?(next_grid, grid) do
      grid
    else
      tilt_grid(next_grid, direction)
    end
  end
  
  def cycle_grid(grid) do
    grid |> tilt_grid({-1, 0})
         |> tilt_grid({0, -1})
         |> tilt_grid({1, 0})
         |> tilt_grid({0, 1})
  end

  def run() do
    grid = puzzle_lines() |> FileUtils.lines_to_grid
    north_grid = tilt_grid(grid, {-1, 0})
    IO.inspect grid_load(north_grid)
    # needed 136 iterations to hit value cycle, length 36
    # Infinite loop logging values for me to find pattern
    final_grid = Stream.cycle(1..2) |> Stream.with_index |> Enum.reduce_while(grid, fn {_, index}, grid -> 
      next_grid = cycle_grid(grid)
      IO.inspect({index + 1, grid_load(next_grid)})
      {:cont, next_grid}
    end)
  end
end


