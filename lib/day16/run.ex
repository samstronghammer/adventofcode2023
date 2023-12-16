
defmodule AdventOfCode.Day16 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  def add_dir({r, c} = _loc, {dr, dc} = _dir) do
    {r + dr, c + dc}
  end

  def simulate(grid, energized, {loc, {drow, dcol} = dir} = _laser_head) do
    if MapSet.member?(energized, {loc, dir}) do
      energized
    else
      new_energized = MapSet.put(energized, {loc, dir})    
      case Map.get(grid, loc) do
        nil -> energized
        "." -> simulate(grid, new_energized, {add_dir(loc, dir), dir})
        "/" -> 
          new_dir = {-dcol, -drow}
          simulate(grid, new_energized, {add_dir(loc, new_dir), new_dir}) 
        "\\" -> 
          new_dir = {dcol, drow}
          simulate(grid, new_energized, {add_dir(loc, new_dir), new_dir}) 
        "-" -> 
          if drow === 0 do
            simulate(grid, new_energized, {add_dir(loc, dir), dir})
          else
            new_dir1 = {0, 1}
            new_dir2 = {0, -1}
            new_energized = simulate(grid, new_energized, {add_dir(loc, new_dir1), new_dir1})
            simulate(grid, new_energized, {add_dir(loc, new_dir2), new_dir2})
          end
        "|" ->
          if dcol === 0 do
            simulate(grid, MapSet.put(energized, {loc, dir}), {add_dir(loc, dir), dir})
          else
            new_dir1 = {1, 0}
            new_dir2 = {-1, 0}
            new_energized = simulate(grid, new_energized, {add_dir(loc, new_dir1), new_dir1})
            simulate(grid, new_energized, {add_dir(loc, new_dir2), new_dir2})
          end
      end 
    end
  end

  def num_energized(grid, laser_head) do
    simulate(grid, MapSet.new(), laser_head) 
      |> Enum.map(&elem(&1, 0)) 
      |> Enum.uniq 
      |> Enum.count
  end

  def run() do
    grid = puzzle_lines() |> FileUtils.lines_to_grid
    IO.inspect num_energized(grid, {{0, 0}, {0, 1}})
    {max_row, max_col} = FileUtils.grid_maximum(grid)
    top_row = 0..max_col |> Enum.map(fn col -> num_energized(grid, {{0, col}, {1, 0}}) end)
    bottom_row = 0..max_col |> Enum.map(fn col -> num_energized(grid, {{max_row, col}, {-1, 0}}) end)
    left_col = 0..max_row |> Enum.map(fn row -> num_energized(grid, {{row, 0}, {0, 1}}) end)
    right_col = 0..max_row |> Enum.map(fn row -> num_energized(grid, {{row, max_col}, {0, -1}}) end)
    IO.inspect Enum.concat([top_row, bottom_row, left_col, right_col]) |> Enum.max
  end
end


