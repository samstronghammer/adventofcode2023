
defmodule AdventOfCode.Day09 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  def get_from_pattern(pattern, :first) do List.first(pattern) end 
  def get_from_pattern(pattern, :last) do List.last(pattern) end 

  def opt_negate(:first) do -1 end 
  def opt_negate(:last) do 1 end 

  def infer(pattern, opt) do
    if Enum.all?(pattern, &(&1===0)) do
      0
    else
      next = Enum.zip(Enum.slice(pattern, 1..-1//1), Enum.slice(pattern, 0..-2//1)) 
               |> Enum.map(fn {x, y} -> x - y end) 
               |> infer(opt)
      get_from_pattern(pattern, opt) + next * opt_negate(opt)
    end
  end

  def run() do
    number_patterns = puzzle_lines() |> FileUtils.extract_numbers()
    IO.inspect number_patterns |> Enum.map(&infer(&1, :last)) |> Enum.sum
    IO.inspect number_patterns |> Enum.map(&infer(&1, :first)) |> Enum.sum
  end
end


