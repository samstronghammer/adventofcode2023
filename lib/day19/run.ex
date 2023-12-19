
defmodule AdventOfCode.Day19 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  defmodule Part do
    defstruct [:x, :m, :a, :s]
  end

  defmodule Rule do
    defstruct [:part_func, :result]
    def from_string(s) do
      toks = String.split(s, ":")
      case toks do
        [result] -> %Rule{part_func: fn _ -> true end, result: result}
        [rule, result] -> %Rule{part_func: fn part = %Part{} -> 
          key = String.to_existing_atom(String.first(rule))
          compare_char = String.at(rule, 1)
          number = String.to_integer(String.slice(rule, 2..-1//1))
          case compare_char do
            "<" -> Map.get(part, key) < number
            ">" -> Map.get(part, key) > number
          end
        end, result: result}
      end
    end
  end

  def get_result(rule_map, part, current_rule_id \\ "in") do
    case current_rule_id do
      "A" -> true
      "R" -> false
      _ -> 
        rules = rule_map[current_rule_id]
        pass_rule = rules |> Enum.find(fn rule -> rule.part_func.(part) end)
        get_result(rule_map, part, pass_rule.result)
    end 
  end

  def run() do
    lines = puzzle_lines() 
    parts = lines |> Enum.filter(&String.starts_with?(&1, "{")) 
                  |> FileUtils.extract_numbers 
                  |> Enum.map(fn [x, m, a, s] -> %Part{x: x, m: m, a: a, s: s} end)
    workflows = lines |> Enum.filter(&!String.starts_with?(&1, "{"))
                      |> Enum.map(fn line -> 
                        [id | rules] = String.split(line, ~r/[\{\},]/) |> Enum.filter(&String.length(&1) !== 0)
                        {id, rules |> Enum.map(&Rule.from_string/1)}
                      end) |> Map.new
    accepted_parts = parts |> Enum.filter(fn part -> get_result(workflows, part) end)
    IO.inspect accepted_parts |> Enum.flat_map(fn part -> [part.x, part.m, part.a, part.s] end) |> Enum.sum
  end
end


