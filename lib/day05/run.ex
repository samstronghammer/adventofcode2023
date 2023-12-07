
defmodule AdventOfCode.Day05 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  defmodule SeedRange do
    defstruct [:start, :length]

    def in_range?(%SeedRange{} = r1, num) do
      num >= r1.start and num < r1.start + r1.length 
    end

    def sort_and_merge(ranges) do
      {stored, tail} = ranges |> Enum.sort_by(&(&1.start), :asc) 
             |> Enum.reduce({[], nil}, fn seed_range, {stored, tail} -> 
               case tail do
                 nil -> {stored, seed_range}
                 _ -> if in_range?(tail, seed_range.start) do
                        {stored, %SeedRange{start: tail.start, length: seed_range.start + seed_range.length - tail.start}}
                      else
                        {stored ++ [tail], seed_range}
                      end
               end
             end)
      stored ++ [tail]
    end
  end

  defmodule AlmanacRange do
    defstruct [:dest_start, :source_start, :range_length] 

    def in_range?(%AlmanacRange{} = range, num) do
      num >= range.source_start and num < range.source_start + range.range_length
    end
    
    def where_in_range(%AlmanacRange{} = range, num) do
      cond do
        num < range.source_start -> :less
        num < range.source_start + range.range_length -> :in
        true -> :more
      end
    end

    def map_range(nil, num) do {:in, num} end
    def map_range(%AlmanacRange{} = range, num) do
      if in_range?(range, num) do
        {:in, num - (range.source_start - range.dest_start)}
      else
        {:out, num}
      end
    end

    def map_range!(%AlmanacRange{} = range, num) do
      if in_range?(range, num) do
        num - (range.source_start - range.dest_start)
      else
        raise "Not in range"
      end
    end
    def map_seed_ranges(%AlmanacRange{} = range, {unused, used}) do
      Enum.reduce(unused, {[], used}, fn unused_seed_range, {unused_acc, used_acc} -> 
        {new_unused, new_used} = map_seed_range(range, unused_seed_range)
        {unused_acc ++ new_unused, used_acc ++ new_used}
      end)
    end
    # {not used, now mapped}
    def map_seed_range(%AlmanacRange{} = range, %SeedRange{} = seed_range) do
      range_end = range.source_start + range.range_length
      seed_range_end = seed_range.start + seed_range.length
      case {where_in_range(range, seed_range.start), where_in_range(range, seed_range.start + seed_range.length - 1)} do
        {:less, :less} -> {[seed_range], []}
        {:less, :in} -> {
          [%{seed_range | length: range.source_start - seed_range.start}], 
          [%SeedRange{start: range.dest_start, length: seed_range.length - (range.source_start - seed_range.start)}]
        } 
        {:less, :more} -> { 
          [%{seed_range | length: range.source_start - seed_range.start},
          %SeedRange{
            start: range_end, 
            length: seed_range.length - (range_end - seed_range.start)
          }],
          [%SeedRange{start: range.dest_start, length: range.range_length}]
        }
        {:in, :in} -> {[], [%SeedRange{length: seed_range.length, start: map_range!(range, seed_range.start)}]}
        {:in, :more} -> {
          [%SeedRange{start: range_end, length: seed_range_end - range_end}],
          [%SeedRange{start: map_range!(range, seed_range.start), length: range_end - seed_range.start}]
        }
        {:more, :more} -> {[seed_range], []}
      end
    end

    def from_list(list) do
      %AlmanacRange{
        dest_start: Enum.at(list, 0),
        source_start: Enum.at(list, 1),
        range_length: Enum.at(list, 2),
      }
    end
  end

  defmodule Almanac do
    defstruct [:seeds, :maps, :seed_ranges]
    defp map_seed(seed, %Almanac{} = almanac) do
      Enum.reduce(almanac.maps, seed, fn map, curr_num -> 
        range_to_use = Enum.find(map, nil, &AlmanacRange.in_range?(&1, curr_num))
        {:in, new_num} = AlmanacRange.map_range(range_to_use, curr_num)
        new_num
      end)
    end
    def map_seeds(%Almanac{} = almanac) do
      almanac.seeds |> Enum.map(&map_seed(&1, almanac))
    end
    
    defp map_seed_ranges_rec(%Almanac{} = almanac, ranges) do
      Enum.reduce(almanac.maps, ranges, fn map, curr_seed_ranges ->
        Enum.flat_map(curr_seed_ranges, fn curr_range -> 
          {unused, used} = Enum.reduce(map, {[curr_range], []}, fn curr_almanac_range, {unused, used} -> 
            AlmanacRange.map_seed_ranges(curr_almanac_range, {unused, used})
          end)
          unused ++ used 
        end) |> SeedRange.sort_and_merge
      end)
    end

    def map_seed_ranges(%Almanac{} = almanac) do
      map_seed_ranges_rec(almanac, almanac.seed_ranges)
    end
  end


  def run() do
    lines = puzzle_lines()
    all_number_lists = lines |> FileUtils.extract_numbers
    [seed_list | rest_lists] = all_number_lists
    seed_ranges = seed_list |> Enum.chunk_every(2) 
                            |> Enum.map(&%SeedRange{start: List.first(&1), length: List.last(&1)})
                            |> SeedRange.sort_and_merge
    maps = rest_lists |> Enum.chunk_by(&Enum.empty?/1) 
                              |> Enum.filter(fn x -> !Enum.empty?(List.first(x)) end)
                              |> Enum.map(fn x -> Enum.map(x, &AlmanacRange.from_list/1) end)
    almanac = %Almanac{seeds: seed_list, maps: maps, seed_ranges: seed_ranges}
    IO.inspect Almanac.map_seeds(almanac) |> Enum.min
    IO.inspect Almanac.map_seed_ranges(almanac) |> Enum.map(&(&1.start)) |> Enum.min
  end
end


