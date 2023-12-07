
defmodule AdventOfCode.Day03 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.Day03

  def point_range({min_row, min_col}, {max_row, max_col}) do
    Stream.flat_map(min_row..max_row, fn row -> min_col..max_col |> Stream.map(&{row, &1}) end) 
  end

  defmodule PartNumber do
    defstruct points: [], number: 0
  end

  defmodule EngineSymbol do
    defstruct [:point, :symbol]
  end


  defmodule EngineSchematic do
    defstruct numbers: [], symbols: []
    
    def add_line(schematic, line, row_index) do
      numbers = Regex.scan(~r/\d+/, line, return: :index, capture: :first)
                  |> Enum.map(fn [{start, length}] ->
                    %PartNumber{
                      points: start..(start + length - 1) 
                                |> Enum.map(fn col_index -> {row_index, col_index} end), 
                      number: String.to_integer(String.slice(line, start, length))
                    }
                  end)
      symbols = Regex.scan(~r/[^\d\.]/, line, return: :index, capture: :first)
                  |> Enum.map(fn [{start, _}] ->
                    %EngineSymbol{point: {row_index, start}, symbol: String.at(line, start)}
                  end)
      %EngineSchematic{
        numbers: schematic.numbers ++ numbers, 
        symbols: schematic.symbols ++ symbols
      }
    end

    def from_lines(lines) do
      lines |> Enum.with_index 
            |> Enum.reduce(%EngineSchematic{}, fn {line, index}, acc -> 
        add_line(acc, line, index)
      end)
    end
    
    def valid_part_number?(%EngineSchematic{} = schematic, %PartNumber{} = number) do
      start_point = List.first(number.points)
      start_row = elem(start_point, 0)
      start_col = elem(start_point, 1)
      length = length(number.points)
      Day03.point_range({start_row - 1, start_col - 1}, {start_row + 1, start_col + length}) 
        |> Enum.any?(fn point_to_check -> Enum.member?(Enum.map(schematic.symbols, &(&1.point)), point_to_check) end)
    end

    def valid_part_numbers(%EngineSchematic{} = schematic) do
      Enum.filter(schematic.numbers, &(EngineSchematic.valid_part_number?(schematic, &1)))
    end

    def get_surrounding_numbers(%EngineSchematic{} = schematic, {row, col}) do
      Day03.point_range({row - 1, col - 1}, {row + 1, col + 1}) 
        |> Enum.map(fn point -> Enum.find(schematic.numbers, nil, &(Enum.member?(&1.points, point))) end)
        |> Enum.filter(&(&1 !== nil))
        |> Enum.uniq()
        |> Enum.map(&(&1.number))
    end
  end


  def run() do
    lines = puzzle_lines()
    schematic = EngineSchematic.from_lines(lines)
    IO.inspect schematic.numbers |> Enum.filter(&EngineSchematic.valid_part_number?(schematic, &1))
                                 |> Enum.map(&(&1.number))
                                 |> Enum.sum
    IO.inspect schematic.symbols |> Enum.filter(&(&1.symbol === "*"))
                                 |> Enum.map(&EngineSchematic.get_surrounding_numbers(schematic, &1.point))
                                 |> Enum.filter(&(length(&1) === 2))
                                 |> Enum.map(&Enum.product/1)
                                 |> Enum.sum
  end
end


