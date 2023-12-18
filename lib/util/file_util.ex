defmodule AdventOfCode.FileUtils do
  defmacro __using__(_opts) do
    quote do
      def test_lines(trim \\ true) do
        module_name = Module.split(__MODULE__) |> Enum.at(1)
        File.read!("lib/#{String.downcase(module_name)}/in2.txt")
          |> String.split("\n", trim: trim)
      end
      def puzzle_lines(trim \\ true) do
        module_name = Module.split(__MODULE__) |> Enum.at(1)
        File.read!("lib/#{String.downcase(module_name)}/in.txt")
          |> String.split("\n", trim: trim)
      end
    end
  end

  @spec extract_numbers_from_line(String.t()) :: Enumerable.t(integer)
  def extract_numbers_from_line(line) do
    extract_regex_from_line(line, ~r/-?\d+/) |> Enum.map(&String.to_integer/1)
  end

  @spec extract_regex_from_line(String.t(), Regex.t()) :: Enumerable.t(String.t())
  def extract_regex_from_line(s, r) do
    Regex.scan(r, s, capture: :first) |> Enum.map(&List.first/1)
  end

  @spec extract_numbers(Enumerable.t(String.t())) :: Enumerable.t(Enumerable.t(integer))
  def extract_numbers(lines) do
    lines |> Enum.map(&(extract_numbers_from_line(&1)))
  end

  @spec lines_to_grid(Enumerable.t(String.t())) :: %{{integer, integer} => String.t()}
  def lines_to_grid(lines) do
    lines |> Enum.with_index |> Enum.flat_map(fn {line, row} -> 
      line |> String.graphemes |> Enum.with_index |> Enum.map(fn {char, col} -> {{row, col}, char} end)
    end) |> Map.new
  end
  
  @spec grid_maximum(%{{integer, integer} => String.t()}) :: {integer, integer}
  def grid_maximum(grid) do
    grid_set_maximum(Map.keys(grid))
  end

  def grid_set_maximum(grid_set) do
    grid_set |> Enum.reduce(fn {row, col}, {max_row, max_col} -> 
      {max(row, max_row), max(col, max_col)}
    end)
  end

  @spec grid_minimum(%{{integer, integer} => String.t()}) :: {integer, integer}
  def grid_minimum(grid) do
    grid_set_minimum(Map.keys(grid))
  end
  
  def grid_set_minimum(grid_set) do
    grid_set |> Enum.reduce(fn {row, col}, {min_row, min_col} -> 
      {min(row, min_row), min(col, min_col)}
    end)
  end

  @spec print_grid(%{{integer, integer} => String.t()}) :: nil
  def print_grid(grid) do
    {max_row, max_col} = grid_maximum(grid)
    0..max_row |> Enum.map(fn row -> 
      line = 0..max_col |> Enum.map_join(fn col -> Map.get(grid, {row, col}) end)
      IO.puts(line)
    end)
    IO.puts("")
    nil
  end
end
