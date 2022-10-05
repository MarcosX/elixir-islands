defmodule IslandsEngine.Coordinate do
  @moduledoc """
  Coordinate represents a row and column id in a board
  """
  alias __MODULE__
  @enforce_keys [:row, :col]
  defstruct [:row, :col]
  @type t :: %__MODULE__{}

  @board_range 1..10

  @spec new(integer, integer) :: {:ok | :error, Coordinate.t() | :invalid_coordinate}
  def new(row, col) when row in @board_range and col in @board_range,
    do: {:ok, %Coordinate{row: row, col: col}}

  def new(_row, _col), do: {:error, :invalid_coordinate}
end
