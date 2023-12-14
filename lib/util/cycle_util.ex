
defmodule AdventOfCode.CycleUtils do
  

  @type value :: any
  @spec calc_big_cycle_index(Enumerable.t(), non_neg_integer, non_neg_integer) :: value 
  def calc_big_cycle_index(stream, goal_index, ignore_first \\ 0) when goal_index > ignore_first do
    stream |> Stream.with_index |> Enum.reduce_while({Map.new(), Map.new()}, fn {{value, hash}, index}, {seen, values} -> 
      if index > ignore_first and Map.has_key?(seen, hash) do 
        old_index = Map.fetch!(seen, hash)
        delta_index = index - old_index
        offset = rem(goal_index, delta_index)
        old_offset = rem(old_index, delta_index)
        {:halt, Map.fetch!(values, old_index - old_offset + offset)}
      else
        {:cont, {Map.put(seen, hash, index), Map.put(values, index, value)}}
      end
    end)
  end
end

