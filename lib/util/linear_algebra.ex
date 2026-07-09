# Copied from https://github.com/SebastianCallh/elixir-linear-algebra and modified to use rational numbers for
# integer precision retention.
#
# License:
# MIT License

# Copyright (c) 2016 Sebastian Callh

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule AdventOfCode.LinearAlgebra do
  defdelegate numerator <~> denominator, to: Ratio, as: :new
  use Numbers, overload_operators: true

  defmodule Vector do

    @moduledoc"""
    Contains  operations for working with vectors.
    """

    @doc"""
    Returns a vector with zeroes with provided dimension.

    ## Examples

        iex> Vector.new(3)
        [0, 0, 0]

    """
    @spec new(number) :: [Ratio]
    def new(n) when not is_number(n),
    do: raise(ArgumentError, "Size provide has to be a number.")
    def new(n) do
      for _ <- 1..n, do: Ratio.new(0, 1)
    end

    @doc"""
    Performs elementwise addition.

    ## Examples

        iex> Vector.add([1, 2, 1], [2, 2, 2])
        [3, 4, 3]

    """
    @spec add([Ratio], [Ratio]) :: [Ratio]
    def add(u, v) when length(u) !== length(v),
    do: raise(ArgumentError, "The number of elements in the vectors must match.")
    def add(u, v) do
      for {a, b} <- Enum.zip(u, v), do: a + b
    end

    @doc"""
    Performs elementwise subtraction.

    ## Examples

        iex> Vector.sub([1, 2, 1], [2, 2, 2])
        [-1, 0, -1]

    """
    @spec sub([Ratio], [Ratio]) :: [Ratio]
    def sub(u, v) when length(u) !== length(v),
    do: raise(ArgumentError, "The number of elements in the vectors must match.")
    @spec sub([Ratio], [Ratio]) :: [Ratio]
    def sub(u, v) do
      add(u, Enum.map(v, fn(x) -> -x end))
    end

    @doc"""
    Elementwise multiplication with a scalar.

    ## Examples

        iex> Vector.mult([2, 2, 2], 2)
        [4, 4, 4]

    """
    @spec scalar([Ratio], Ratio) :: [Ratio]
    def scalar(v, s) do
      Enum.map(v, fn(x) -> x*s end)
    end
  end

  @doc"""
  Pivots them matrix a on the element on row n, column m (zero indexed).
  Pivoting performs row operations to make the
  pivot element 1 and all others in the same column 0.

  ## Examples

      iex> Matrix.pivot([[2.0, 3.0],
      ...>               [2.0, 3.0],
      ...>               [3.0, 6.0]], 1, 0)
      [[0.0, 0.0],
       [1.0, 1.5],
       [0.0, 1.5]]

  """
  @spec pivot([[Ratio]], number, number) :: [[Ratio]]
  def pivot(a, n, m) do
    pr = Enum.at(a, n)  #Pivot row
    pe = Enum.at(pr, m) #Pivot element
    a
      |> List.delete_at(n)
      |> Enum.map(&Vector.sub(&1, Vector.scalar(pr, Enum.at(&1, m) / pe)))
      |> List.insert_at(n, Vector.scalar(pr, 1 / pe))
  end

  @doc"""
  Returns a row equivalent matrix on reduced row echelon form.

  ## Examples

      iex> Matrix.reduce([[1.0, 1.0, 2.0, 1.0],
      ...>                [2.0, 1.0, 6.0, 4.0],
      ...>                [1.0, 2.0, 2.0, 3.0]])
      [[1.0, 0.0, 0.0, -5.0],
       [0.0, 1.0, 0.0, 2.0],
       [0.0, 0.0, 1.0, 2.0]]

  """
  @spec reduce([[Ratio]]) :: [[Ratio]]
  def reduce(a), do: reduce(a, 0)
  defp reduce(a, i) do
    r = Enum.at(a, i)
    j = Enum.find_index(r, fn(e) -> e != Ratio.new(0, 1) end)
    a = pivot(a, i, j)
    unless j === length(r) - 1 or
           i === length(a) - 1 do
      reduce(a, i + 1)
    else
      a
    end
  end
end
