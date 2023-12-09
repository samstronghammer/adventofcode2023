
defmodule AdventOfCode.Day08 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  def ends_with?(s, letter) do
    String.last(s) === letter
  end

  def cycle_length(start_node, pattern, node_map) do
    pattern |> Stream.cycle() |> Enum.reduce_while({start_node, 0}, fn lr, {node, count} -> 
      if ends_with?(node, "Z") do
        {:halt, count}
      else
        {:cont, {node_map[node][lr], count + 1}}
      end
    end)
  end

  def run() do
    lines = puzzle_lines()
    pattern = List.first(lines) |> String.to_charlist
    nodes = Enum.slice(lines, 1..-1//1) |> Enum.map(&FileUtils.extract_regex_from_line(&1, ~r/[A-Z]{3}/))
    node_map = Map.new(nodes, fn node_list -> 
      {List.first(node_list), %{?L => Enum.at(node_list, 1), ?R => Enum.at(node_list, 2)}}
    end)
    IO.inspect cycle_length("AAA", pattern, node_map)
    IO.inspect nodes |> Enum.map(&List.first/1) 
                     |> Enum.filter(&ends_with?(&1, "A")) 
                     |> Enum.map(&cycle_length(&1, pattern, node_map))
                     |> Enum.reduce(&Math.lcm/2)
  end
end


