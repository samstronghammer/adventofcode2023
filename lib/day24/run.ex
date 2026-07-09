
defmodule AdventOfCode.Day24 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils
  alias AdventOfCode.LinearAlgebra

  @puzzle_min 200000000000000
  @puzzle_max 400000000000000


  defmodule Hailstone do
    defstruct [:x, :y, :z, :dx, :dy, :dz]

    def get_m_b(stone = %Hailstone{}) do
      m = stone.dy/stone.dx
      b = stone.y - m * stone.x
      {m, b}
    end

    def get_intersection(s1 = %Hailstone{}, s2 = %Hailstone{}) do
      {m1, b1} = get_m_b(s1)
      {m2, b2} = get_m_b(s2)
      case {m1 === m2, b1 === b2} do
        {true, true} -> true
        {true, false} -> false
        _ ->
          x = (b2 - b1)/(m1 - m2)
          y = m1 * x + b1
          {x, y}
      end
    end

    def sign(int) when int === 0 do 0 end
    def sign(int) when int > 0 do 1 end
    def sign(int) when int < 0 do -1 end

    def make_constraint_xy(s0, s1) do
      #(dy'-dy) X + (dx-dx') Y + (y-y') DX + (x'-x) DY = x' dy' - y' dx' - x dy + y dx
      [(s1.dy - s0.dy), (s0.dx - s1.dx), (s0.y - s1.y), (s1.x - s0.x), s1.x * s1.dy - s1.y * s1.dx - s0.x * s0.dy + s0.y * s0.dx]
    end

    def make_constraint_xz(s0, s1) do
      #(dz'-dz) X + (dx-dx') Z + (z-z') DX + (x'-x) DZ = x' dz' - z' dx' - x dz + z dx
      [(s1.dz - s0.dz), (s0.dx - s1.dx), (s0.z - s1.z), (s1.x - s0.x), s1.x * s1.dz - s1.z * s1.dx - s0.x * s0.dz + s0.z * s0.dx]
    end

    def in_future(s = %Hailstone{}, {x, y}) do
      sign(x - s.x) === sign(s.dx) and sign(y - s.y) === sign(s.dy)
    end

    def count_intersections(hailstones, min_range, max_range) do
      for s1 <- hailstones, s2 <- hailstones do
        if s1 === s2 do
          false
        else
          case get_intersection(s1, s2) do
            {x, y} ->
              in_future(s1, {x, y}) and in_future(s2, {x, y}) and x >= min_range and x <= max_range and y >= min_range and y <= max_range
            b -> b
          end
        end
      end |> Enum.count(&(&1)) |> div(2)
    end
  end

  def run() do
    hailstones = puzzle_lines() |> FileUtils.extract_numbers |> Enum.map(
      fn [x, y, z, dx, dy, dz] -> %Hailstone{x: x, y: y, z: z, dx: dx, dy: dy, dz: dz} end
    )
    IO.inspect Hailstone.count_intersections(hailstones, @puzzle_min, @puzzle_max)

    first_8 = hailstones |> Enum.take(8) |> Enum.chunk_every(2) # make pairs of stones for building up equations

    my_matrix_y = first_8
      |> Enum.map(fn [s1, s2] ->
        Hailstone.make_constraint_xy(s1, s2)
          |> Enum.map(fn num -> Ratio.new(num, 1) end)
      end)
      |> LinearAlgebra.reduce

    ans = my_matrix_y |> Enum.map(fn [_, _, _, _, a] -> a.numerator end)
    [x, y, dx, _dy] = ans


    my_matrix_z = first_8
      |> Enum.map(fn [s1, s2] ->
        Hailstone.make_constraint_xz(s1, s2)
          |> Enum.map(fn num -> Ratio.new(num, 1) end)
      end)
      |> LinearAlgebra.reduce

    ans = my_matrix_z |> Enum.map(fn [_, _, _, _, a] -> a.numerator end)
    [x2, z, dx2, _dz] = ans

    if x != x2 or dx != dx2 do
      raise "answers do not match"
    end
    IO.inspect x + y + z
  end
end
