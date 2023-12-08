defmodule AdventOfCode.FileUtils do
  defmacro __using__(_opts) do
    quote do
      def test_lines() do
        module_name = Module.split(__MODULE__) |> Enum.at(1)
        File.read!("lib/#{String.downcase(module_name)}/in2.txt")
          |> String.split("\n", trim: true)
      end
      def puzzle_lines() do
        module_name = Module.split(__MODULE__) |> Enum.at(1)
        File.read!("lib/#{String.downcase(module_name)}/in.txt")
          |> String.split("\n", trim: true)
      end
    end
  end

  @spec extract_numbers_from_line(String.t()) :: Enumerable.t(integer)
  def extract_numbers_from_line(line) do
    extract_regex_from_line(line, ~r/\d+/) |> Enum.map(&String.to_integer/1)
  end

  @spec extract_regex_from_line(String.t(), Regex.t()) :: Enumerable.t(String.t())
  def extract_regex_from_line(s, r) do
    Regex.scan(r, s, capture: :first) |> Enum.map(&List.first/1)
  end

  @spec extract_numbers(Enumerable.t(String.t())) :: Enumerable.t(Enumerable.t(integer))
  def extract_numbers(lines) do
    lines |> Enum.map(&(extract_numbers_from_line(&1)))
  end
  
end
