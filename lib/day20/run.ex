
defmodule AdventOfCode.Day20 do
  use AdventOfCode.FileUtils

  # pulled from https://www.programming-idioms.org/idiom/75/compute-lcm/983/elixir
  defmodule MathUtil do
    def gcd(a, 0), do: a
    def gcd(0, b), do: b
    def gcd(a, b), do: gcd(b, rem(a,b))

    def lcm(0, 0), do: 0
    def lcm(a, b), do: div((a*b), gcd(a,b))
  end

  def type_to_initial_state(type) do
    case type do
      "%" -> :off
      "&" -> %{}
      "b" -> :none
    end
  end
                                                         # {FROM, PULSE, TO}
  def handle_pulses(modules, presses, pulses \\ :queue.from_list([{"button", :low, "roadcaster"}])) do
    case :queue.out(pulses) do
      {:empty, _} -> {0, 0, modules}
      {{:value, {from_name, pulse_type, name}}, pulses} ->
        # Records all the press count times that various modules emit pulses
        # used for p2
        modules = if Map.has_key?(modules, from_name) do
          from_state = modules[from_name]
          {prev_low, prev_high} = elem(from_state, 3)
          new_recorded = case pulse_type do
            :low -> {[presses | prev_low], prev_high}
            :high -> {prev_low, [presses | prev_high]}
          end
          Map.replace!(modules, from_name, {elem(from_state, 0), elem(from_state, 1), elem(from_state, 2), new_recorded})
        else
          modules
        end

        if Map.has_key?(modules, name) do
          {type, dest_modules, state, recorded_pulses} = modules[name]
          {state, pulse_to_send} = case {type, state, pulse_type} do
            {"%", _, :high} -> {state, :none}
            {"%", :on, :low} -> {:off, :low}
            {"%", :off, :low} -> {:on, :high}
            {"&", _, _} ->
              state = Map.put(state, from_name, pulse_type)
              pulse_to_send = if Map.values(state) |> Enum.all?(& &1 === :high) do
                :low
              else
                :high
              end
              {state, pulse_to_send}
            {"b", _, _} -> {state, pulse_type}
          end
          pulses = dest_modules |> Enum.reduce(pulses, fn dest_module, pulses ->
            if pulse_to_send !== :none do
              :queue.in({name, pulse_to_send, dest_module}, pulses)
            else
              pulses
            end
          end)
          modules = Map.replace!(modules, name, {type, dest_modules, state, recorded_pulses})
          {low_pulses, high_pulses, modules} = handle_pulses(modules, presses, pulses)
          case pulse_type do
            :low -> {low_pulses + 1, high_pulses, modules}
            :high -> {low_pulses, high_pulses + 1, modules}
          end
        else
          {low_pulses, high_pulses, modules} = handle_pulses(modules, presses, pulses)
          case pulse_type do
            :low -> {low_pulses + 1, high_pulses, modules}
            :high -> {low_pulses, high_pulses + 1, modules}
          end
        end
    end
  end

  def calc_initial_inputs(modules, name_to_find) do
    modules |> Enum.filter(fn {_, {_, dest_modules, _, _}} ->
      Enum.member?(dest_modules, name_to_find)
    end) |> Enum.map(fn {name, _} -> {name, :low} end) |> Map.new
  end

  # Only works if the first number is equal to the period.
  def calc_period_of_presses(backward_nums) do
    if length(backward_nums) < 3 do
      nil
    else
      nums = backward_nums |> Enum.reverse
      [first, second, third | _rest] = nums
      period = first
      if second - first != period or third - second != period do
        raise "period not constant with no offset, need better estimation"
      end
      period
    end
  end

  def merge_periods(periods) do
    case length(periods) do
      0 -> nil
      1 -> List.first(periods)
      _ ->
        [first, second | rest] = periods
        new_period = MathUtil.lcm(first, second)
        merge_periods([new_period | rest])
    end
  end

  # Keep trying presses until all the important inputs have shown their periods
  def calc_p2_ans(modules, presses, input_module_keys) do
    input_offset_periods = input_module_keys |> Enum.map(fn key ->
      {_, _, _, {_low_recorded, high_recorded}} = Map.get(modules, key)
      calc_period_of_presses(high_recorded)
    end)
    all_found = input_offset_periods |> Enum.all?(fn obj -> obj != nil end)
    if all_found do
      input_offset_periods
    else
      {_, _, new_modules} = handle_pulses(modules, presses + 1)
      calc_p2_ans(new_modules, presses + 1, input_module_keys)
    end
  end

  def run() do
    modules = puzzle_lines() |> Enum.map(fn line ->
      [name_and_type, dest_modules] = String.split(line, " -> ")
      {type, name} = String.split_at(name_and_type, 1)
      {name, {type, String.split(dest_modules, ", "), type_to_initial_state(type), {[], []}}}
    end) |> Map.new
    modules = modules |> Enum.map(fn {name, {type, dest_modules, _, recorded_pulses} = metadata} ->
      case type do
        "&" -> {name, {type, dest_modules, calc_initial_inputs(modules, name), recorded_pulses}}
        _ -> {name, metadata}
      end
    end) |> Map.new
    {low, high, new_modules} = 1..1000 |> Enum.reduce({0, 0, modules}, fn presses, {low, high, modules} ->
      {new_low, new_high, new_modules} = handle_pulses(modules, presses)
      {new_low + low, new_high + high, new_modules}
    end)
    IO.inspect low * high

    rx_input = new_modules |> Enum.find(fn {_key, {_, outputs, _, _}} ->
      Enum.member?(outputs, "rx")
    end)
    input_module_keys = Map.keys(elem(elem(rx_input, 1), 2))
    IO.inspect merge_periods(calc_p2_ans(new_modules, 1000, input_module_keys))
  end
end
