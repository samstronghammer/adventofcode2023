defmodule AdventOfCode do
  defmacro __using__(_opts) do
    quote do
      def test_lines() do
        [module_name | _] = Module.split(__MODULE__)
        File.read!("lib/#{String.downcase(module_name)}/in2.txt")
          |> String.split("\n", trim: true)
      end
      def puzzle_lines() do
        [module_name | _] = Module.split(__MODULE__)
        File.read!("lib/#{String.downcase(module_name)}/in.txt")
          |> String.split("\n", trim: true)
      end
    end
  end
end
