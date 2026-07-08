
defmodule AdventOfCode.Day25 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils
  alias AdventOfCode.PathUtil

  def nodes_to_pair(n1, n2) do
    [first, second | _] = Enum.sort([n1, n2])
    {first, second}
  end

  def get_path(start_node, end_node, out_edges, removed_edges) do
    node_path = PathUtil.dijkstra(start_node, fn n -> n == end_node end, fn n ->
      my_edges = Map.get(out_edges, n) |> Enum.filter(fn edge -> !Enum.member?(removed_edges, edge) end)
      neighbors = my_edges |> Enum.map(fn {n1, n2} ->
        neighbor = if n == n1 do
          n2
        else
          n1
        end
        {neighbor, 1}
      end)
      neighbors
    end)
    if length(node_path) == 0 do
      nil # No path found
    else
      [_first | shifted_path] = node_path
      Enum.zip(node_path, shifted_path) |> Enum.map(fn {n1, n2} -> nodes_to_pair(n1, n2) end)
    end
  end

  def try_pair(start_node, end_node, out_edges, removed_edges) do
    path = get_path(start_node, end_node, out_edges, removed_edges)
    if length(removed_edges) == 3 do
      if path === nil do
        removed_edges
      else
        nil
      end
    else
      # Not yet removed three edges. Try removing one in the path.
      path |> Enum.find_value(nil, fn edge ->
        try_pair(start_node, end_node, out_edges, [edge | removed_edges])
      end)
    end
  end

  # Try going from a start node to each other node, testing if the path can
  # be broken by removing 3 wires. Return those wires if found.
  def find_wires(nodes, out_edges) do
    [first_node | rest_of_nodes] = nodes |> MapSet.to_list
    rest_of_nodes = rest_of_nodes |> Enum.shuffle # in case all the nodes around the first node are at the beginning too.
    rest_of_nodes |> Enum.find_value(nil, fn other_node ->
      try_pair(first_node, other_node, out_edges, [])
    end)
  end

  def flood_fill(frontier, visited, out_edges, removed_edges) do
    if MapSet.size(frontier) == 0 do
      visited
    else
      visited = MapSet.union(frontier, visited)
      frontier = frontier |> Enum.flat_map(fn node ->
        my_edges = Map.get(out_edges, node) |> Enum.filter(fn edge -> !Enum.member?(removed_edges, edge) end)
        neighbors = my_edges |> Enum.map(fn {n1, n2} ->
          neighbor = if node == n1 do
            n2
          else
            n1
          end
          neighbor
        end)
        neighbors |> Enum.filter(fn neighbor -> !Enum.member?(visited, neighbor) end)
      end) |> MapSet.new
      flood_fill(frontier, visited, out_edges, removed_edges)
    end
  end

  def run() do
    input = puzzle_lines() |> Enum.map(&FileUtils.extract_regex_from_line(&1, ~r/[a-z]{3}/))
    edges = input |> Enum.flat_map(fn input_array ->
      [from_node | to_nodes] = input_array
      to_nodes |> Enum.map(fn to_node ->
        nodes_to_pair(from_node, to_node)
      end)
    end) |> MapSet.new
    nodes = edges |> Enum.flat_map(fn {n1, n2} -> [n1, n2] end) |> MapSet.new
    out_edges = nodes |> Enum.map(fn node ->
      these_out_edges = edges |> Enum.filter(fn {n1, n2} -> n1 == node or n2 == node end)
      {node, these_out_edges}
    end) |> Map.new
    wires_to_remove = find_wires(nodes, out_edges)
    group_1 = flood_fill([Enum.fetch!(nodes, 0)] |> MapSet.new, MapSet.new(), out_edges, wires_to_remove)
    group_1_size = group_1 |> MapSet.size
    IO.inspect group_1_size * (MapSet.size(nodes) - group_1_size)
  end
end
