defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine.Coordinate
  alias IslandsEngine.Coordinate

  test "valid coordinate" do
    assert Coordinate.new(1, 1) == {:ok, %Coordinate{col: 1, row: 1}}
  end

  test "out of bounds invalid coordinates" do
    assert Coordinate.new(1, 11) == {:error, :invalid_coordinate}
    assert Coordinate.new(11, 1) == {:error, :invalid_coordinate}
    assert Coordinate.new(-1, 1) == {:error, :invalid_coordinate}
    assert Coordinate.new(1, -11) == {:error, :invalid_coordinate}
  end
end
