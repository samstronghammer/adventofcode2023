
defmodule AdventOfCode.Day01 do
  use AdventOfCode.FileUtils

  defp is_digit?(c) when c >= ?0 and c <= ?9, do: true
  defp is_digit?(_), do: false 

  @number_names ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  
  defp maybe_reverse(enumerable, :reverse) do enumerable |> Enum.reverse end
  defp maybe_reverse(enumerable, _) do enumerable end

  defp find_number(line, part, reverse \\ nil) do
    line |> String.to_charlist |> Enum.with_index |> maybe_reverse(reverse) |> Enum.find_value(fn {char, index} ->
      substring = String.slice(line, index..-1//1)
      cond do
        is_digit?(char) -> char - 48
        part === :p2 -> Enum.find_index(@number_names, &String.starts_with?(substring, &1))
        true -> nil
      end
    end)
  end

  defp line_to_int_2(line, part) do
    10 * find_number(line, part) + find_number(line, part, :reverse)
  end

  def run() do
    lines = puzzle_lines()
    IO.inspect lines |> Enum.map(&line_to_int_2(&1, :p1))
                     |> Enum.sum
    IO.inspect lines |> Enum.map(&line_to_int_2(&1, :p2))
                     |> Enum.sum
  end
end




