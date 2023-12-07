
defmodule AdventOfCode.Day04 do
  use AdventOfCode.FileUtils
  alias AdventOfCode.FileUtils

  defmodule ScratchCard do
    defstruct [:id, :winning_numbers, :your_numbers, :num_winning, :score]
    

    def to_score(num_winning) do
      case num_winning do
        0 -> 0
        _ -> :math.pow(2, num_winning - 1)
      end
    end

    def from_string(s) do
      [id_string, winning_string, your_string] = String.split(s, ~r/[\:\|]/)
      winning_numbers = FileUtils.extract_numbers_from_line(winning_string)
      your_numbers = FileUtils.extract_numbers_from_line(your_string)
      num_winning = your_numbers |> Enum.count(fn x -> Enum.member?(winning_numbers, x) end)
      %ScratchCard{
        id: hd(FileUtils.extract_numbers_from_line(id_string)),
        winning_numbers: FileUtils.extract_numbers_from_line(winning_string),
        your_numbers: FileUtils.extract_numbers_from_line(your_string),
        num_winning: num_winning,
        score: to_score(num_winning)
      }
    end
    
    def num_cards_won(%ScratchCard{} = card, _, id_to_cache) when card.num_winning === 0 do
      {1, id_to_cache}
    end

    def num_cards_won(%ScratchCard{} = card, _, %{} = id_to_cache) when is_map_key(id_to_cache, card.id) do
      
      {Map.fetch!(id_to_cache, card.id), id_to_cache}
    end

    def num_cards_won(%ScratchCard{} = card, %{} = id_to_card, %{} = id_to_cache) do
      ids_won = (card.id + 1)..(card.id + card.num_winning)
      {num_won, id_to_cache} = num_cards_won(ids_won, id_to_card, id_to_cache)
      {num_won + 1, Map.put(id_to_cache, card.id, num_won + 1)}
    end

    def num_cards_won(%Range{} = card_ids, %{} = id_to_card, %{} = id_to_cache) do
      Enum.reduce(card_ids, {0, id_to_cache}, fn id, {num_won, id_to_cache} -> 
        case Map.fetch(id_to_card, id) do
          {:ok, new_card} -> 
            {new_won, new_id_to_cache} = num_cards_won(new_card, id_to_card, id_to_cache) 
            {new_won + num_won, new_id_to_cache}
          _ -> {num_won, id_to_cache}
        end
      end)
    end
    def run_simulation(cards) do
      card_map = Map.new(cards, fn card -> {card.id, card} end)
      {num_won, _} = num_cards_won(1..length(cards), card_map, %{})    
      num_won
    end
  end


  def run() do
    lines = puzzle_lines()
    scratch_cards = lines |> Enum.map(&ScratchCard.from_string/1)
    IO.inspect scratch_cards 
                 |> Enum.map(&(&1.score))
                 |> Enum.sum
    IO.inspect ScratchCard.run_simulation(scratch_cards)
  end
end




