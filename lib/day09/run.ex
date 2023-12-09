
defmodule AdventOfCode.Day09 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  def infer(pattern) do
    if Enum.all?(pattern, &(&1===0)) do
      0
    else
      next = Enum.zip(Enum.slice(pattern, 1..-1//1), Enum.slice(pattern, 0..-2//1)) 
               |> Enum.map(fn {x, y} -> x - y end) 
               |> infer
      List.last(pattern) + next
    end
  end

  def run() do
    number_patterns = puzzle_lines() |> FileUtils.extract_numbers()
    IO.inspect number_patterns |> Enum.map(&infer/1) |> Enum.sum
    IO.inspect number_patterns |> Enum.map(&infer(Enum.reverse(&1))) |> Enum.sum
  end
end


