
defmodule AdventOfCode.Day18 do
  use AdventOfCode.FileUtils

  def dir_char_to_tuple(char) do
    case char do
      "U" -> {-1, 0}
      "D" -> {1, 0}
      "R" -> {0, 1}
      "L" -> {0, -1}
    end
  end

  def hex_to_dir(hex_string) do
    case hex_string do
      "0" -> "R"
      "1" -> "D"
      "2" -> "L"
      "3" -> "U"
    end |> dir_char_to_tuple
  end

  def calc_corners(instructions, part) do
    instructions |> Enum.map_reduce(
      {0, 0}, 
      fn instruction, {row, col} -> 
        {{delta_row, delta_col}, number} = get_instruction_data(instruction, part) 
        new_position = {row + delta_row * number, col + delta_col * number}
        {new_position, new_position}
      end) |> elem(0)
  end
  
  def get_instruction_data({dir_char, number, color}, part) do
    case part do
      :p1 -> {dir_char_to_tuple(dir_char), number}
      :p2 -> {
        color |> String.last |> hex_to_dir, 
        color |> String.slice(1, 5) |> to_charlist |> List.to_integer(16)
      }
    end
  end
 
  def run() do
    instructions = puzzle_lines() |> Enum.map(fn line -> 
      toks = String.split(line, ~r/[ \(\)]/)
      {Enum.at(toks, 0), String.to_integer(Enum.at(toks, 1)), Enum.at(toks, 3)}
    end)
    corners1 = calc_corners(instructions, :p1)
    IO.inspect Point2D.polygon_grid_area(corners1)
    corners2 = calc_corners(instructions, :p2)
    IO.inspect Point2D.polygon_grid_area(corners2)
  end
end


