
defmodule AdventOfCode.Day10 do
  use AdventOfCode.FileUtils
  
  def add_dir({row, col}, travel_dir) do
    case travel_dir do
      :north -> {row - 1, col}
      :south -> {row + 1, col}
      :east -> {row, col + 1} 
      :west -> {row, col - 1}
    end
  end

  def get_dir({curr_row, curr_col}, {prev_row, prev_col}) do
    case {curr_row - prev_row, curr_col - prev_col} do
      {1, 0} -> :south
      {-1, 0} -> :north
      {0, 1} -> :east 
      {0, -1} -> :west
    end
  end
  
  def get_char({row, col}, lines) do
    if row >= length(lines) or col >= String.length(hd(lines)) do
      "."
    else
      Enum.at(lines, row) |> String.at(col)
    end
  end

  def find_start(lines) do
    lines |> Enum.with_index |> Enum.reduce_while(nil, fn {line, row}, _acc -> 
      col = Enum.find_index(String.to_charlist(line), &(&1 === ?S))
      case col do
        nil -> {:cont, nil}
        col -> {:halt, {row, col}}
      end
    end)
  end

  def next_pos(curr_pos, prev_pos, lines) do
    travel_dir = get_dir(curr_pos, prev_pos)
    char_string = get_char(curr_pos, lines)
    new_direction = case {char_string, travel_dir} do
      {"|", :north} -> :north 
      {"|", :south} -> :south 
      {"-", :east} -> :east 
      {"-", :west} -> :west 
      {"L", :south} -> :east 
      {"L", :west} -> :north 
      {"J", :south} -> :west 
      {"J", :east} -> :north 
      {"7", :east} -> :south 
      {"7", :north} -> :west 
      {"F", :north} -> :east
      {"F", :west} -> :south
      _ -> nil
    end
    if new_direction === nil do
      nil
    else
      add_dir(curr_pos, new_direction) 
    end
  end

  def build_path(path, lines) do
    curr_pos = Enum.at(path, -1)
    prev_pos = Enum.at(path, -2)
    next_pos = next_pos(curr_pos, prev_pos, lines)
    if next_pos === nil do
      path
    else
      build_path(path ++ [next_pos], lines)
    end
  end

  def point_range({min_row, min_col}, {max_row, max_col}) do
    Stream.flat_map(min_row..max_row, fn row -> min_col..max_col |> Stream.map(&{row, &1}) end) 
  end

  def run() do
    lines = puzzle_lines() 
    start_pos = find_start(lines)
    start_paths = [
      [start_pos, add_dir(start_pos, :north)],
      [start_pos, add_dir(start_pos, :east)],
      [start_pos, add_dir(start_pos, :south)],
      [start_pos, add_dir(start_pos, :west)],
    ]
    loop_path = start_paths |> Enum.reduce_while(nil, fn path, _acc -> 
      built_path = build_path(path, lines)
      if List.last(built_path) === List.first(built_path) do
        {:halt, built_path}
      else
        {:cont, nil}
      end
    end)
    IO.inspect (length(loop_path) - 1) / 2
    loop_chars = Map.new(loop_path, fn pos -> {pos, get_char(pos, lines)} end)

    line_length = String.length(hd(lines))
    total = 0..(length(lines) - 1) |> Enum.map(fn row -> 
      {total, _, _} = Enum.reduce(0..(line_length - 1), {0, 0, nil}, fn col, {total, borders_crossed, prev_turn} -> 
        curr_char = Map.get(loop_chars, {row, col})
        case {curr_char, rem(borders_crossed, 4), prev_turn} do
          {nil, 2, _} -> {total + 1, borders_crossed, prev_turn}
          {nil, _, _} -> {total, borders_crossed, prev_turn}
          {"-", _, _} -> {total, borders_crossed, prev_turn}
          {"|", _, _} -> {total, borders_crossed + 2, nil}
          {"L", _, _} -> {total, borders_crossed + 1, "L"}
          {"J", _, "F"} -> {total, borders_crossed + 1, nil}
          {"J", _, _} -> {total, borders_crossed - 1, nil}
          {"7", _, "L"} -> {total, borders_crossed + 1, nil}
          {"7", _, _} -> {total, borders_crossed - 1, nil}
          {"F", _, _} -> {total, borders_crossed + 1, "F"}
          {"S", _, _} -> {total, borders_crossed, prev_turn}# special case dependent on input
        end
      end)
      total
    end) |> Enum.sum
    IO.inspect total
  end
end


