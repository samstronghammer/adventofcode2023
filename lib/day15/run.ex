
defmodule AdventOfCode.Day15 do
  use AdventOfCode.FileUtils

  def hash(s) do
    s |> String.to_charlist |> Enum.reduce(0, fn c, acc -> 
      rem((acc + c) * 17, 256)
    end)
  end
  
  def do_removal(boxes, id, hash_value) do
    Map.put(boxes, hash_value, Enum.filter(Map.get(boxes, hash_value, []), fn {item_id, _} -> item_id !== id end))
  end

  def do_insertion_to_list(list, id, focal_length) do
    found_item_index = Enum.find_index(list, fn {item_id, _item_focal_length} -> item_id === id end)
    if found_item_index === nil do
      list ++ [{id, focal_length}]
    else
      List.replace_at(list, found_item_index, {id, focal_length})
    end
  end

  def do_insertion(boxes, id, hash_value, focal_length) do
    new_list = do_insertion_to_list(Map.get(boxes, hash_value, []), id, focal_length)
    Map.put(boxes, hash_value, new_list)
  end

  def do_operation(boxes, operation) do
    id = Regex.run(~r/^[a-z]+/, operation) |> List.first
    hash_value = hash(id)
    if String.last(operation) === "-" do
      do_removal(boxes, id, hash_value)
    else
      do_insertion(boxes, id, hash_value, (String.to_charlist(operation) |> List.last) - 48)
    end
  end

  def run() do
    codes = puzzle_lines() |> List.first |> String.split(",")
    filled_boxes = codes |> Enum.reduce(%{}, fn code, boxes -> 
      do_operation(boxes, code)
    end)
    IO.inspect codes |> Enum.map(&hash/1) |> Enum.sum
    IO.inspect filled_boxes |> Enum.flat_map(fn {hash_value, lens_list} -> 
      lens_list |> Enum.with_index |> Enum.map(fn {{_, focal_length}, index} -> 
        (hash_value + 1) * (index + 1) * (focal_length) 
      end)
    end) |> Enum.sum
  end
end


