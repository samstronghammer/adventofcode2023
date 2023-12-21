
defmodule AdventOfCode.Day21 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  @big_step_number 26501365

  def adj4({row, col}) do
    [{row + 1, col}, {row - 1, col}, {row, col + 1}, {row, col - 1}]  
  end
  
  def num_plots_rec(rocks, next_step, num_steps, frontier, even_plots, odd_plots) do
    if next_step > num_steps do
      if rem(num_steps, 2) === 0 do
        even_plots
      else
        odd_plots
      end
    else
      next_frontier = frontier 
        |> Enum.flat_map(&adj4/1) 
        |> Enum.filter(fn loc -> 
            !MapSet.member?(frontier, loc) and 
            !MapSet.member?(even_plots, loc) and 
            !MapSet.member?(odd_plots, loc) and 
            !MapSet.member?(rocks, loc) 
          end)
        |> MapSet.new
      {even_plots, odd_plots} = case rem(next_step, 2) do
        0 -> {MapSet.union(even_plots, frontier), odd_plots}
        1 -> {even_plots, MapSet.union(odd_plots, frontier)}
      end
      num_plots_rec(rocks, next_step + 1, num_steps, next_frontier, even_plots, odd_plots)
    end
  end

  def num_plots(rocks, start_position, num_steps) when num_steps >= 0 do
    num_plots_rec(rocks, 0, num_steps, MapSet.new([start_position]), MapSet.new(), MapSet.new())
  end


  @doc """
  The input allows for some big assumptions-- there is an moat empty of rocks
  in the shape of a diamond around the start point, which divides the infinite
  plane of gardens into a nice diamond-shaped grid, which repeats easily.
  If there were more rocks preventing clean modular algebra, this wouldn't work.
  There are 3 types of diamonds calculated, which repeat. The math counts the 
  number of each diamond and the number of possibilities in each diamond type
  and composes them. The A diamonds are the copies of the central diamond.
  There are Ao and Ae to handle the odd offset and even offset versions. There
  are also B diamonds, which are made of the 4 corners of the original input.
  These also have odd and even counterparts, but are counted in pairs, so we 
  only need to calculate the number of positions in a pair, then multiply by the 
  number of pairs. It looks something like this: 
                     Ao
                   Be  Bo
                 Ao  Ae  Ao
               Be  Bo  Be  Bo
             Ao  Ae  Ao  Ae  Ao
               Bo  Be  Bo  Be
                 Ao  Ae  Ao
                   Bo  Be    
                     Ao
  which repeats, alternating odd/even/B/A in that pattern in all directions.
  There is one additional term for the answer, subtracting about half of
  the number of blocks on a side. I'm not 100% sure why that term is necessary,
  it just came up while testing. The answer got 1 off for each additional
  circumference of blocks added.
  """
  def calc_big_steps(grid, rocks, start_position, step_num) do
    assert_assumptions(grid, start_position, step_num)

    {center_index, _} = start_position
    width = center_index * 2 + 1
    num_blocks_edge = div(step_num - center_index, width) * 2 + 1
    a_e = (num_blocks_edge - 1) |> div(2) |> Math.pow(2)
    a_o = (num_blocks_edge + 1) |> div(2) |> Math.pow(2)
    # number of b block pairs
    b_t = (num_blocks_edge |> Math.pow(2)) - (a_o + a_e) |> div(2)

    a_o_count = num_plots(rocks, start_position, center_index) |> MapSet.size
    a_e_count = num_plots(rocks, start_position, center_index - 1) |> MapSet.size

    full_o_count = num_plots(rocks, start_position, center_index - 1 + width) 
      |> Enum.count(fn loc -> Map.has_key?(grid, loc) end) 
    full_e_count = num_plots(rocks, start_position, center_index + width) 
      |> Enum.count(fn loc -> Map.has_key?(grid, loc) end) 
    b_t_count = full_o_count + full_e_count - a_o_count - a_e_count
    a_o * a_o_count + a_e * a_e_count + b_t * b_t_count - div(num_blocks_edge - 1, 2)
  end

  def assert_assumptions(grid, start_position, step_num) do
    {max_row, max_col} = FileUtils.grid_maximum(grid)
    {start_row, start_col} = start_position
    ^max_row = max_col
    ^start_row = start_col
    ^max_row = (start_row * 2) # Handles row/col, because equal
    0 = rem(max_row, 2)
    ^start_row = rem(step_num, max_row + 1) 
    # Asterisk, does not check for empty moat.
  end

  def run() do
    grid = puzzle_lines() |> FileUtils.lines_to_grid
    start_position = Map.keys(grid) |> Enum.find(fn loc -> Map.get(grid, loc) === "S" end)
    rocks = grid |> Enum.filter(fn {_loc, char} -> char === "#" end) 
                 |> Enum.map(fn {loc, _char} -> loc end) 
                 |> MapSet.new
    reached_points = num_plots(rocks, start_position, 64)
    IO.inspect MapSet.size(reached_points)
    IO.inspect calc_big_steps(grid, rocks, start_position, @big_step_number)
  end
end

