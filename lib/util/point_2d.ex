defmodule Point2D do
  
  def manhattan_distance({r1, c1}, {r2, c2}) do
    abs(r1 - r2) + abs(c1 - c2)
  end

  def polygon_area(coord_list) do
    pairs = Enum.zip(coord_list, Enum.drop(coord_list ++ [List.first(coord_list)], 1))
    pairs |> Enum.map(fn {p1, p2} -> 
      (elem(p1, 0) * elem(p2, 1)) -
      (elem(p1, 1) * elem(p2, 0))
    end) |> Enum.sum |> div(2) |> abs
  end

  def polygon_perimeter(coord_list) do
    pairs = Enum.zip(coord_list, Enum.drop(coord_list ++ [List.first(coord_list)], 1))
    pairs |> Enum.map(fn {p1, p2} -> manhattan_distance(p1, p2) end) |> Enum.sum
  end

  def polygon_grid_area(coord_list) do
    area = polygon_area(coord_list)
    perimeter = polygon_perimeter(coord_list)
    area + div(perimeter, 2) + 1 
  end
end
