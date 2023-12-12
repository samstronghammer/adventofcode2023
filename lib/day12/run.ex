
defmodule AdventOfCode.Day12 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils
  
  defmodule Cache do
    use Agent
    def start_link() do
      Agent.start_link(&Map.new/0, name: __MODULE__)
    end

    def get(key) do
      Agent.get(__MODULE__, &Map.get(&1, key))
    end

    def put(key, value) do
      Agent.update(__MODULE__, &Map.put(&1, key, value))
    end
  end

  def number_fits({_symbols, [] = _numbers}) do false end
  def number_fits({symbols, [first | _rest]}) do
    String.match?(symbols, ~r/^[#?]{#{first}}($|[\.?])/)
  end
   
  def num_arrangements_helper({_symbols, [] = _numbers}) do 0 end
  def num_arrangements_helper({symbols, [first | rest] = numbers}) do
    if number_fits({symbols, numbers}) do
      num_arrangements({String.slice(symbols, first + 1, String.length(symbols)), rest})
    else
      0
    end
  end

  def num_arrangements({"", []}) do 1 end    
  def num_arrangements({"", _numbers}) do 0 end    
  def num_arrangements({symbols, numbers} = pair) do    
    value = Cache.get(pair)
    if value === nil do
      {char, rest} = String.split_at(symbols, 1)
      ans = case char do
        "." -> num_arrangements({rest, numbers})
        "#" -> num_arrangements_helper(pair)
        "?" -> num_arrangements({"." <> rest, numbers}) + num_arrangements({"#" <> rest, numbers}) 
      end
      Cache.put(pair, ans)
      ans
    else
      value
    end
  end

  def run() do
    spring_pairs = puzzle_lines() |> Enum.map(fn line -> 
      [symbols, numbers] = String.split(line, " ")
      {symbols, FileUtils.extract_numbers_from_line(numbers)}
    end)
    {:ok, _} = Cache.start_link()
    IO.inspect spring_pairs |> Enum.map(&num_arrangements/1) |> Enum.sum
    IO.inspect spring_pairs |> Enum.map(fn {symbols, numbers} -> 
      {1..5 |> Enum.map(fn _ -> symbols end) |> Enum.join("?"), 1..5 |> Enum.flat_map(fn _ -> numbers end)}
    end) |> Enum.map(&num_arrangements/1) |> Enum.sum
  end
end


