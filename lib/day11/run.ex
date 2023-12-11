
defmodule AdventOfCode.Day11 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  @p2_scale_factor 1_000_000

  def manhattan_distance({r1, c1}, {r2, c2}) do
    abs(r1 - r2) + abs(c1 - c2)
  end

  def count_galaxy_distances(galaxies, scale_factor, empty_rows, empty_cols) do
    galaxies = galaxies 
      |> Enum.map(fn {row, col} ->
        row_inc = empty_rows |> Enum.count(&(&1 < row))
        col_inc = empty_cols |> Enum.count(&(&1 < col))
        {row + row_inc * (scale_factor - 1), col + col_inc * (scale_factor - 1)}
      end) |> MapSet.new
    for g1 <- galaxies, g2 <- galaxies do
      # Don't need to special case when galaxy is paired with itself because the distance is 0
      manhattan_distance(g1, g2)
    end |> Enum.sum |> div(2)
  end

  def run() do
    lines = puzzle_lines()
    galaxies = lines |> FileUtils.lines_to_grid 
                        |> Enum.filter(fn {_point, char} -> char === "#" end)
                        |> Enum.map(&(elem(&1, 0)))
                        |> MapSet.new
    max_row = length(lines) - 1
    max_col = (List.first(lines) |> String.length) - 1
    empty_rows = 0..max_row |> Enum.filter(
      fn row -> Enum.all?(galaxies, 
        fn {point_row, _} -> point_row !== row end
      ) end
    )
    empty_cols = 0..max_col |> Enum.filter(
      fn col -> Enum.all?(galaxies, 
        fn {_, point_col} -> point_col !== col end
      ) end
    )
    IO.inspect count_galaxy_distances(galaxies, 2, empty_rows, empty_cols)
    IO.inspect count_galaxy_distances(galaxies, @p2_scale_factor, empty_rows, empty_cols)
  end
end


