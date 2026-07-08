
defmodule AdventOfCode.Day22 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  defmodule BRange do
    defstruct [:min, :max]
    def in_range?(r = %BRange{}, v) do
      v >= r.min and v <= r.max
    end

    def range_intersect?(r1 = %BRange{}, r2 = %BRange{}) do
      in_range?(r1, r2.min) or
      in_range?(r1, r2.max) or
      in_range?(r2, r1.min) or
      in_range?(r2, r1.max)
    end
  end

  defmodule Brick do
    defstruct [:x, :y, :z, :id]

    def intersect?(b1 = %Brick{}, b2 = %Brick{}) do
      BRange.range_intersect?(b1.x, b2.x) and
      BRange.range_intersect?(b1.y, b2.y) and
      BRange.range_intersect?(b1.z, b2.z)
    end

    def below(b = %Brick{}) do
      %Brick{x: b.x, y: b.y, z: %BRange{min: b.z.min - 1, max: b.z.min - 1}, id: b.id}
    end

    def above(b = %Brick{}) do
      %Brick{x: b.x, y: b.y, z: %BRange{min: b.z.max + 1, max: b.z.max + 1}, id: b.id}
    end

    def move_down_n(b = %Brick{}, n) do
      %Brick{x: b.x, y: b.y, z: %BRange{min: b.z.min - n, max: b.z.max - n}, id: b.id}
    end

    def shadow(b = %Brick{}) do
      %Brick{x: b.x, y: b.y, z: %BRange{min: 1, max: b.z.min - 1}, id: b.id}
    end
  end

  def calc_space_below(settled_bricks, moving_brick) do
    shadow = Brick.shadow(moving_brick)
    intersecting_bricks = settled_bricks |> Enum.filter(fn settled_brick ->
      Brick.intersect?(shadow, settled_brick)
    end)
    if length(intersecting_bricks) == 0 do
      moving_brick.z.min - 1
    else
      highest_brick = intersecting_bricks |> Enum.max_by(& &1.z.max)
      moving_brick.z.min - highest_brick.z.max - 1
    end
  end

  def move_down(moving_bricks, settled_bricks \\ []) do
    if length(moving_bricks) === 0 do
      settled_bricks
    else
      [bottom_moving | moving_bricks] = moving_bricks
      space_below = calc_space_below(settled_bricks, bottom_moving)
      new_settled = Brick.move_down_n(bottom_moving, space_below)
      move_down(moving_bricks, [new_settled | settled_bricks])
    end
  end

  # Calculates a map from brick -> set of bricks that will cause it to fall.
  # You can calculate the set for a particular brick based on the sets from
  # the brick underneath it. Intersection of all the sets of the bricks underneath, and
  # add the brick underneath if there is only one.
  def calculate_fall_sets(frontier, cache, bricks_depend_on_me_map, bricks_i_depend_on_map) do
    if length(frontier) === 0 do
      cache
    else
      new_frontier = frontier
        |> Enum.flat_map(fn brick -> bricks_depend_on_me_map[brick] end)
        |> Enum.filter(fn brick ->
          bricks_i_depend_on_map[brick] |> Enum.all?(fn under_brick ->
            Map.has_key?(cache, under_brick)
          end)
        end)
      cache_additions = new_frontier |> Enum.map(fn brick ->
        under_sets = bricks_i_depend_on_map[brick] |> Enum.map(fn under_brick -> Map.get(cache, under_brick) end)
        my_set = under_sets |> Enum.reduce(List.first(under_sets), fn under_set, acc ->
          MapSet.intersection(under_set, acc)
        end)
        final_set = if length(bricks_i_depend_on_map[brick]) === 1 do
          MapSet.put(my_set, List.first(bricks_i_depend_on_map[brick]))
        else
          my_set
        end
        {brick, final_set}
      end) |> Map.new
      calculate_fall_sets(new_frontier, Map.merge(cache, cache_additions), bricks_depend_on_me_map, bricks_i_depend_on_map)
    end
  end

  def run() do
    bricks = puzzle_lines() |> FileUtils.extract_numbers()
                          |> Enum.map(fn [minx, miny, minz, maxx, maxy, maxz] ->
                            if minx > maxx or miny > maxy or minz > maxz do
                              throw "ranges not as expected"
                            end
                            %Brick{
                              x: %BRange{min: minx, max: maxx},
                              y: %BRange{min: miny, max: maxy},
                              z: %BRange{min: minz, max: maxz},
                              id: 3,
                            }
                          end)

    settled_bricks = move_down(bricks |> Enum.sort_by(& &1.z.min, :asc))
    bricks_i_depend_on_map = settled_bricks |> Enum.map(fn brick ->
      space_below = Brick.below(brick)
      i_depend_on = settled_bricks |> Enum.filter(fn other_brick -> Brick.intersect?(other_brick, space_below) end)
      {brick, i_depend_on}
    end) |> Map.new
    bricks_depend_on_me_map = settled_bricks |> Enum.map(fn brick ->
      space_above = Brick.above(brick)
      depend_on_me = settled_bricks |> Enum.filter(fn other_brick -> Brick.intersect?(other_brick, space_above) end)
      {brick, depend_on_me}
    end) |> Map.new

    IO.inspect settled_bricks |> Enum.count(fn brick ->
      # find bricks that depend on me
      # If all of them have other dependencies, ok
      bricks_depend_on_me_map[brick] |> Enum.all?(fn brick2 ->
        length(bricks_i_depend_on_map[brick2]) > 1
      end)
    end)

    ground_bricks = settled_bricks |> Enum.filter(& &1.z.min === 1)
    initial_cache = ground_bricks |> Enum.map(fn brick ->
      {brick, MapSet.new()}
    end) |> Map.new

    final_cache = calculate_fall_sets(ground_bricks, initial_cache, bricks_depend_on_me_map, bricks_i_depend_on_map)
    IO.inspect settled_bricks |> Enum.map(& MapSet.size(Map.get(final_cache, &1))) |> Enum.sum
  end
end
