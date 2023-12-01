defmodule Point2D do
  defstruct x: 0, y: 0
  
  def add(p1, p2) do
    %Point2D{x: p1.x + p2.x, y: p1.y + p2.y}
  end
  
  def sub(p1, p2) do
    %Point2D{x: p1.x - p2.x, y: p1.y - p2.y}
  end

  def up() do %Point2D{x: 0, y: 1} end
end
