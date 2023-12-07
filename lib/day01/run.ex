
defmodule AdventOfCode.Day01 do
  use AdventOfCode.FileUtils

  defp is_digit?(c) when c >= ?0 and c <= ?9, do: true
  defp is_digit?(_), do: false 

  @number_names %{one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9}
  
  defp line_to_int(line) do
    ints = line |> String.to_charlist |> Enum.filter(&is_digit?/1) |> Enum.map(&(&1 - 48))
    10 * List.first(ints) + List.last(ints)
  end

  def name_to_number(name) do
    case name do
      "one" -> 1
      "1" -> 1
      "two" -> 2
      "2" -> 2
      "three" -> 3
      "3" -> 3
      "four" -> 4
      "4" -> 4
      "five" -> 5
      "5" -> 5
      "six" -> 6
      "6" -> 6
      "seven" -> 7
      "7" -> 7
      "eight" -> 8
      "8" -> 8
      "nine" -> 9
      "9" -> 9
    end
  end

  def replace_number_names(line) do
    first_regex = ~r/(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|(\d)/
    last_regex = ~r/(eno)|(owt)|(eerht)|(ruof)|(evif)|(xis)|(neves)|(thgie)|(enin)|(\d)/
    first_match = first_regex
                    |> Regex.run(line, capture: :first) 
                    |> List.first 
                    |> name_to_number
    last_match = last_regex 
                   |> Regex.run(String.reverse(line), capture: :first) 
                   |> List.first 
                   |> String.reverse 
                   |> name_to_number
    10 * first_match + last_match
  end

  def run() do
    lines = puzzle_lines()
    IO.inspect lines 
                 |> Enum.map(&line_to_int/1)
                 |> Enum.sum
    IO.inspect lines 
                 |> Enum.map(&replace_number_names/1)
                 |> Enum.sum
  end
end




