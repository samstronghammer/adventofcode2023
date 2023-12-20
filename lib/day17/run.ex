
defmodule AdventOfCode.Day17 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.PathUtil
  alias AdventOfCode.FileUtils

  def sign(int) when int === 0 do 0 end
  def sign(int) when int > 0 do 1 end
  def sign(int) when int < 0 do -1 end

  def turn_left({drow, dcol}) do {-dcol, drow} end
  def turn_right({drow, dcol}) do {dcol, -drow} end
  
  def straight_distance({_, _, moved_row, moved_col}) do
    max(abs(moved_row), abs(moved_col))
  end

  def heat_loss(grid, path) do
    Enum.drop(path, 1) 
     |> Enum.map(fn {row, col, _, _} -> String.to_integer(Map.get(grid, {row, col})) end) 
     |> Enum.sum
  end

  def find_path(grid, min_moved, max_moved) do
    {max_row, max_col} = FileUtils.grid_maximum(grid)
    start = {0, 0, 0, 0}
    goal = {max_row, max_col, 0, 0}
    heuristic = fn {row, col, _, _} -> (max_row - row) + (max_col - col) end
    valid_point = fn {row, col, _, _} -> 
      row >= 0 and row <= max_row and col >= 0 and col <= max_col
    end
    get_neighbors = fn {row, col, moved_row, moved_col} = v1 -> 
      options = case {row, col} do
        {0, 0} -> [{1, 0, 1, 0}, {0, 1, 0, 1}]
        _ -> 
          dir = {sign(moved_row), sign(moved_col)}
          {straight_drow, straight_dcol} = dir
          {left_drow, left_dcol} = turn_left(dir)
          {right_drow, right_dcol} = turn_right(dir)
          moved = straight_distance(v1)
          [
            moved < max_moved and {row + straight_drow, col + straight_dcol, moved_row + straight_drow, moved_col + straight_dcol},
            moved >= min_moved and {row + left_drow, col + left_dcol, left_drow, left_dcol},
            moved >= min_moved and {row + right_drow, col + right_dcol, right_drow, right_dcol}
          ] 
      end
      options |> Enum.filter(&(&1)) |> Enum.filter(valid_point) 
        |> Enum.map(fn {row, col, moved_row, moved_col} = v2 -> 
        v2 = case {row, col} do
          {^max_row, ^max_col} when moved_row >= min_moved or moved_col >= min_moved -> {max_row, max_col, 0, 0}
          _ -> v2
        end
        {v2, String.to_integer(Map.get(grid, {row, col}))}
      end)
    end
    PathUtil.a_star(start, goal, heuristic, get_neighbors)
  end

  def run() do
    grid = puzzle_lines() |> FileUtils.lines_to_grid()
    IO.inspect heat_loss(grid, find_path(grid, 0, 3))
    IO.inspect heat_loss(grid, find_path(grid, 4, 10))
  end
end

