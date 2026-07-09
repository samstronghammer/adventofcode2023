defmodule Adventofcode2023.MixProject do
  use Mix.Project

  def project do
    [
      app: :adventofcode2023,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [d: ["compile", &run_day/1], all: ["compile", &run_all_days/1]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def run_day(args) do
    [num] = args
    apply(String.to_atom("Elixir.AdventOfCode.Day#{String.pad_leading(num, 2, "0")}"), :run, [])
  end

  def run_all_days(_args) do
    1..25 |> Enum.each(fn n ->
      args = [Integer.to_string(n)]
      message = "Day " <> Integer.to_string(n)
      IO.puts message
      run_day(args)
    end)
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:math, "~> 0.6.0"},
      {:heap, "~> 3.0"},
      {:ratio, "~> 4.0"}
    ]
  end
end
