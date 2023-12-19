
defmodule AdventOfCode.Day19 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  defmodule Part do
    defstruct [:x, :m, :a, :s]

    def initialize(v) do
      %Part{x: v, m: v, a: v, s: v}
    end

    def part_number_of_combinations(p = %Part{}) do
      MapSet.size(p.x) * MapSet.size(p.m) * MapSet.size(p.a) * MapSet.size(p.s) 
    end
  end

  defmodule Rule do
    defstruct [:part_func, :part_set_func, :result]

    def apply_char("<", rule_number, value) do value < rule_number end
    def apply_char(">", rule_number, value) do value > rule_number end

    def from_string(s) do
      toks = String.split(s, ":")
      case toks do
        [result] -> %Rule{
          part_func: fn _ -> true end, 
          part_set_func: fn set -> {set, Part.initialize(MapSet.new())} end, 
          result: result
        }
        [rule, result] -> 
          key = String.to_existing_atom(String.first(rule))
          compare_char = String.at(rule, 1)
          number = String.to_integer(String.slice(rule, 2..-1//1))
          %Rule{
            part_func: 
              fn part = %Part{} -> 
                apply_char(compare_char, number, Map.get(part, key))
              end, 
            part_set_func:
              fn part_set = %Part{} ->
                {succeed, fail} = Map.get(part_set, key) |> Enum.split_with(&apply_char(compare_char, number, &1))
                {Map.put(part_set, key, succeed |> MapSet.new), Map.put(part_set, key, fail |> MapSet.new)}
              end,
            result: result
          }
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

  def get_number_of_combos(rule_map, part_set, current_rule_id \\ "in") do
    case current_rule_id do
      "A" -> Part.part_number_of_combinations(part_set) 
      "R" -> 0
      _ ->
        rules = rule_map[current_rule_id]
        {_, number_of_combos} = rules |> Enum.reduce(
          {part_set, 0}, 
          fn rule, {parts_havent_matched_yet, number_of_combos} -> 
            {succeed_set, fail_set} = rule.part_set_func.(parts_havent_matched_yet)
            recurse_combos = get_number_of_combos(rule_map, succeed_set, rule.result)
            {fail_set, number_of_combos + recurse_combos}
          end)
        number_of_combos 
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
    part_set = Part.initialize((1..4000 |> MapSet.new))
    result = get_number_of_combos(workflows, part_set)
    IO.inspect result
  end
end


