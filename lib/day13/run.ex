
defmodule AdventOfCode.Day13 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils
  
  def swap_rows_and_cols(grid) do
    grid |> Enum.map(fn {{row, col}, char} -> {{col, row}, char} end) |> Map.new
  end
  
  def row_index_reflects(grid, reflect_index, num_smudges) when reflect_index > 0 do
    num_smudges * 2 === (grid |> Enum.count(fn {{row, col}, char} -> 
      new_row = 2 * reflect_index - row - 1
      case Map.get(grid, {new_row, col}) do
        nil -> false 
        char_reflected -> char_reflected !== char
      end
    end))
  end

  def find_reflect_index(grid, max_row_index, num_smudges) do
    1..max_row_index |> Enum.find(&row_index_reflects(grid, &1, num_smudges))
  end

  def summarize(grid, num_smudges) do
    {max_row, max_col} = FileUtils.grid_maximum(grid)
    reflect_row = find_reflect_index(grid, max_row, num_smudges)
    reflect_col = find_reflect_index(swap_rows_and_cols(grid), max_col, num_smudges)
    case {reflect_row, reflect_col} do
      {nil, nil} -> raise "Both nil"
      {row, nil} -> 100 * row
      {nil, col} -> col
      _ -> raise "Both defined"
    end
  end

  def run() do
    grids = puzzle_lines(false) 
      |> Enum.chunk_while([], fn line, acc -> 
        if line === "" do
          {:cont, Enum.reverse(acc), []}
        else
          {:cont, [line | acc]}
        end
      end, fn [] -> {:cont, []} end) 
      |> Enum.map(&FileUtils.lines_to_grid/1) 
    IO.inspect grids |> Enum.map(&summarize(&1, 0)) |> Enum.sum
    IO.inspect grids |> Enum.map(&summarize(&1, 1)) |> Enum.sum
  end
end

