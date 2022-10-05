defmodule IslandsEngine.Board do
  @moduledoc """
  Board tracks ilands and guesses for a player
  """
  alias IslandsEngine.Island

  @spec new :: %{}
  def new, do: %{}

  @doc """
  Position an `island` of `island_type` on the `board`

  ## Example
      iex> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, island} = Island.new(:square, island_coordinate)
      ...> Board.position_island(Board.new(), :square, island)
      %{square: island}

      iex> board = Board.new()
      ...> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, square_island} = Island.new(:square, island_coordinate)
      ...> {:ok, dot_island} = Island.new(:dot, island_coordinate)
      ...> board = Board.position_island(board, :square, square_island)
      ...> Board.position_island(board, :dot, dot_island)
      {:error, :overlapping_island}
  """
  @spec position_island(%{}, atom, Island.t()) :: {:error, :overlapping_island} | %{}
  def position_island(board, island_type, %Island{} = island) do
    case overlaps_existing_island?(board, island_type, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, island_type, island)
    end
  end

  defp overlaps_existing_island?(board, new_island_type, new_island) do
    Enum.any?(board, fn {island_type, island} ->
      island_type != new_island_type and Island.overlaps?(island, new_island)
    end)
  end
end
