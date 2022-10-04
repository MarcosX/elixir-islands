defmodule IslandsEngine.IslandTest do
  use ExUnit.Case
  alias IslandsEngine.{Island, Coordinate}
  doctest Island

  test "invalid out of bounds island" do
    {:ok, upper_left_coordinate} = Coordinate.new(10, 10)
    assert Island.new(:square, upper_left_coordinate) == {:error, :invalid_island_position}
  end

  test "invalid wrong type island" do
    {:ok, upper_left_coordinate} = Coordinate.new(1, 1)
    assert Island.new(:not_a_valid_type, upper_left_coordinate) == {:error, :invalid_island_type}
  end
end
