
defmodule AdventOfCode.Day23 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.PathUtil
  alias AdventOfCode.FileUtils

  def cell_neighbors(loc, grid, part) do
    neighbors = Point2D.adj4(loc) |> Enum.filter(fn loc_2 ->
      case Map.get(grid, loc_2) do
        nil -> false
        "#" -> false
        "." -> true
        ">" -> part === :p2 or elem(loc, 1) < elem(loc_2, 1)
        "v" -> part === :p2 or elem(loc, 0) < elem(loc_2, 0)
      end
    end)
    neighbors
  end

  def find_intersections(grid) do
    grid |> Enum.filter(fn {loc, char} ->
      case char do
        "#" -> false
        _ ->
          adj4 = Point2D.adj4(loc)
          num_paths = adj4 |> Enum.count(fn loc ->
            Map.has_key?(grid, loc) and Map.fetch!(grid, loc) !== "#"
          end)
          num_paths > 2
      end
    end) |> Enum.map(fn {loc, _char} -> loc end) |> MapSet.new
  end

  def get_neighboring_intersections(grid, intersections, frontier, seen, part) do
    if length(frontier) === 0 do
      MapSet.intersection(intersections, seen)
    else
      [new_point | frontier] = frontier
      new_seen = MapSet.put(seen, new_point)
      if MapSet.member?(intersections, new_point) or MapSet.member?(seen, new_point) do
        get_neighboring_intersections(grid, intersections, frontier, new_seen, part)
      else
        new_points = cell_neighbors(new_point, grid, part)
        get_neighboring_intersections(grid, intersections, new_points ++ frontier, new_seen, part)
      end
    end
  end

  # Map from intersection to map from intersection to distance
  def calculate_intersection_distances(grid, start_pos, end_pos, part) do
    intersections = find_intersections(grid)
    intersections = MapSet.put(intersections, start_pos)
    intersections = MapSet.put(intersections, end_pos)
    for intersection <- intersections do
      neighboring_intersections =
        get_neighboring_intersections(grid, MapSet.delete(intersections, intersection), [intersection], MapSet.new(), part)
      {
        intersection,
        neighboring_intersections
          |> Enum.map(fn neighbor ->
            filtered_grid = grid |> Enum.filter(fn {loc, _} ->
              !MapSet.member?(intersections, loc) or loc === intersection or loc === neighbor
            end) |> Map.new
            path_to_neighbor = PathUtil.dijkstra(
              intersection,
              fn loc -> loc === neighbor end,
              fn loc -> cell_neighbors(loc, filtered_grid, part) |> Enum.map(&({&1, 1})) end
            )
            {neighbor, length(path_to_neighbor) - 1}
          end)
          |> Map.new
      }
    end |> Map.new

  end

  def topsort(l, s, distances) do
    if length(s) === 0 do
      l |> Enum.reverse
    else
      [n | s] = s
      l = [n | l]
      distances = Map.delete(distances, n)
      no_incoming = distances |> Enum.filter(fn {loc, _} ->
        !Enum.any?(distances, fn {_, distance_map} -> Map.has_key?(distance_map, loc) end)
      end) |> Enum.map(fn {loc, _} -> loc end)
      s = (s ++ no_incoming) |> Enum.uniq
      topsort(l, s, distances)
    end
  end

  def calc_longest_dists(distances, sorted_points) do
    longest_dists = sorted_points |> Enum.map(fn point ->
      if point === List.first(sorted_points) do
        {point, 0}
      else
        {point, -1_000_000_000}
      end
    end) |> Map.new
    longest_dists = Enum.reduce(sorted_points, longest_dists, fn point, longest_dists ->
      point_dist = Map.get(longest_dists, point)
      longest_dists |> Enum.map(fn {other_point, other_dist} ->
        new_dist = case Map.fetch!(distances, point) |> Map.get(other_point) do
          nil -> other_dist
          v -> max(other_dist, point_dist + v)
        end
        {other_point, new_dist}
      end) |> Map.new
    end)
    Map.get(longest_dists, List.last(sorted_points))
  end

  # DFS finding longest path, multi-threaded for speed.
  def calc_longest_path_distance(curr_pos, past_path, past_dist, distances, end_pos) do
    past_path = [curr_pos | past_path]
    if curr_pos === end_pos do
      past_dist
    else
      other_position_pairs = Map.get(distances, curr_pos) # neighbors with distances
        |> Enum.filter(fn {other_pos, _} -> !Enum.member?(past_path, other_pos) end) # filter out neighbors that are already visited
      options = if length(past_path) < 8 do # NOTE adjust the path length check for different number of cores
         other_position_pairs
          |> Enum.map(fn {other_pos, dist_to_other} ->
            Task.Supervisor.async(LongestPathSupervisor, fn ->
              calc_longest_path_distance(other_pos, past_path, past_dist + dist_to_other, distances, end_pos) # calc longest path going through this specific neighbor
            end)
          end)
          |> Task.await_many(:infinity)
      else
        other_position_pairs
          |> Enum.map(fn {other_pos, dist_to_other} ->
            calc_longest_path_distance(other_pos, past_path, past_dist + dist_to_other, distances, end_pos) # calc longest path going through this specific neighbor
          end)
      end
      [0 | options] |> Enum.max # 0 is fallback, indicating no path to end
    end
  end

  def run() do
    grid = puzzle_lines() |> FileUtils.lines_to_grid()
    {row_max, col_max} = FileUtils.grid_maximum(grid)
    start_pos = {0, 1}
    end_pos = {row_max, col_max - 1}
    distances = calculate_intersection_distances(grid, start_pos, end_pos, :p1)
    sorted_points = topsort([], [start_pos], distances)
    IO.inspect calc_longest_dists(distances, sorted_points)
    distances = calculate_intersection_distances(grid, start_pos, end_pos, :p2)
    {:ok, _} = Supervisor.start_link([
      {Task.Supervisor, name: LongestPathSupervisor}
    ], strategy: :one_for_one)
    d = calc_longest_path_distance(start_pos, [], 0, distances, end_pos) # Multithreaded for speed. May need to tune number of threads for different computers.
    IO.inspect d
  end
end
