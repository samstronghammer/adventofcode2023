defmodule FileUtil do

  @spec extract_numbers_from_line(String.t()) :: Enumerable.t(integer)
  defp extract_numbers_from_line(line) do
    Regex.scan(~r/\d+/, line, capture: :first) |> Enum.map(&List.first/1) |> Enum.map(&String.to_integer/1)
  end
  
  @spec extract_numbers(Enumerable.t(String.t())) :: Enumerable.t(Enumerable.t(integer))
  def extract_numbers(lines) do
    lines |> Enum.map(&(extract_numbers_from_line(&1)))
  end
  
  def parse_file() do
    
  end

end
