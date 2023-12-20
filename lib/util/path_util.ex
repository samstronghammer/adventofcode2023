defmodule AdventOfCode.PathUtil do

  def a_star(start, goal, heuristic, get_neighbors) do
    frontier = Heap.new(fn {_v1, f1}, {_v2, f2} -> f1 < f2 end)
    frontier = Heap.push(frontier, {start, heuristic.(start)})
    came_from = Map.new()
    g_score = Map.new([{start, 0}])
    seen = MapSet.new()
    a_star_rec(goal, heuristic, get_neighbors, frontier, came_from, g_score, seen)
  end
  
  defp a_star_reconstruct_path(came_from, current, path) when not is_map_key(came_from, current) do [current | path] end
  defp a_star_reconstruct_path(came_from, current, path) do
    a_star_reconstruct_path(came_from, Map.get(came_from, current), [current | path])
  end

  defp a_star_rec(goal, heuristic, get_neighbors, 
                  frontier, came_from, g_score, seen) do
    {{current, _}, frontier} = Heap.split(frontier)
    cond do
      current === goal -> a_star_reconstruct_path(came_from, current, [])
      MapSet.member?(seen, current) -> a_star_rec(goal, heuristic, get_neighbors, frontier, came_from, g_score, seen)
      true -> 
        neighbors = get_neighbors.(current)
        {frontier, came_from, g_score} = neighbors |> 
          Enum.reduce({frontier, came_from, g_score}, fn {neighbor_v, neighbor_d}, {frontier, came_from, g_score} -> 
            tentative_g_score = Map.fetch!(g_score, current) + neighbor_d
            if not Map.has_key?(g_score, neighbor_v) or Map.fetch!(g_score, neighbor_v) > tentative_g_score do
              came_from = Map.put(came_from, neighbor_v, current)
              g_score = Map.put(g_score, neighbor_v, tentative_g_score)
              frontier = Heap.push(frontier, {neighbor_v, tentative_g_score + neighbor_d})
              {frontier, came_from, g_score}
            else
              {frontier, came_from, g_score}
            end
          end)
        a_star_rec(goal, heuristic, get_neighbors, frontier, came_from, g_score, MapSet.put(seen, current))
      end
    end
end
