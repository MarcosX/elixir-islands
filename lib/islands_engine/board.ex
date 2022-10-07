defmodule IslandsEngine.Board do
  @moduledoc """
  Board tracks ilands and guesses for a player
  """
  alias IslandsEngine.{Coordinate, Island}

  @spec new :: %{}
  def new, do: %{}

  @doc """
  Position an `island` of `island_type` on the `board`

  ## Examples
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

  @doc """
  Check if all island types are on the `board`

  ## Examples
      iex> board = Board.new()
      ...> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, island} = Island.new(:dot, island_coordinate)
      ...> board = Board.position_island(board, :dot, island)
      ...> {:ok, island_coordinate} = Coordinate.new(1, 2)
      ...> {:ok, island} = Island.new(:square, island_coordinate)
      ...> board = Board.position_island(board, :square, island)
      ...> {:ok, island_coordinate} = Coordinate.new(2, 1)
      ...> {:ok, island} = Island.new(:l_shape, island_coordinate)
      ...> board = Board.position_island(board, :l_shape, island)
      ...> {:ok, island_coordinate} = Coordinate.new(5, 1)
      ...> {:ok, island} = Island.new(:atoll, island_coordinate)
      ...> board = Board.position_island(board, :atoll, island)
      ...> {:ok, island_coordinate} = Coordinate.new(5, 5)
      ...> {:ok, island} = Island.new(:s_shape, island_coordinate)
      ...> board = Board.position_island(board, :s_shape, island)
      ...> Board.all_islands_positioned?(board)
      true

      iex> board = Board.new()
      ...> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, island} = Island.new(:dot, island_coordinate)
      ...> board = Board.position_island(board, :dot, island)
      ...> {:ok, island_coordinate} = Coordinate.new(1, 2)
      ...> {:ok, island} = Island.new(:square, island_coordinate)
      ...> board = Board.position_island(board, :square, island)
      ...> {:ok, island_coordinate} = Coordinate.new(2, 1)
      ...> {:ok, island} = Island.new(:l_shape, island_coordinate)
      ...> board = Board.position_island(board, :l_shape, island)
      ...> Board.all_islands_positioned?(board)
      false
  """
  @spec all_islands_positioned?(%{}) :: boolean
  def all_islands_positioned?(board) do
    Enum.all?(Island.types(), &Map.has_key?(board, &1))
  end

  @doc """
  Guess a `coordinate` on a `board` and returns:
  1) guess hit or miss
  2) what island type has been forested
  3) whether all islands have been forested
  4) the transformed board after the guess

  ## Examples
      iex> board = Board.new()
      ...> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, island} = Island.new(:square, island_coordinate)
      ...> board = Board.position_island(board, :square, island)
      ...> {:ok, guess_coordinate} = Coordinate.new(1, 1)
      ...> {_hit_or_miss, _island_forested, _win_or_no_win, board} = Board.guess(board, guess_coordinate)
      {:hit, :none, :no_win, board}

      iex> board = Board.new()
      ...> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, island} = Island.new(:dot, island_coordinate)
      ...> board = Board.position_island(board, :dot, island)
      ...> {:ok, guess_coordinate} = Coordinate.new(1, 1)
      ...> {_hit_or_miss, _island_forested, _win_or_no_win, board} = Board.guess(board, guess_coordinate)
      {:hit, :dot, :win, board}

      iex> board = Board.new()
      ...> {:ok, island_coordinate} = Coordinate.new(1, 1)
      ...> {:ok, island} = Island.new(:square, island_coordinate)
      ...> board = Board.position_island(board, :square, island)
      ...> {:ok, guess_coordinate} = Coordinate.new(3, 3)
      ...> {_hit_or_miss, _island_forested, _win_or_no_win, board} = Board.guess(board, guess_coordinate)
      {:miss, :none, :no_win, board}
  """
  @type island_type :: :square | :atoll | :dot | :l_shape | :s_shape
  @spec guess(%{}, Coordinate.t()) :: {:hit | :miss, island_type | :none, :win | :no_win, %{}}
  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {island_type, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {island_type, island}
        :miss -> false
      end
    end)
  end

  defp guess_response({island_type, island}, board) do
    board = %{board | island_type => island}
    {:hit, forest_check(board, island_type), win_check(board), board}
  end

  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp all_forested?(board) do
    Enum.all?(board, fn {_island_type, island} -> Island.forested?(island) end)
  end

  defp forest_check(board, island_type) do
    case forested?(board, island_type) do
      true -> island_type
      false -> :none
    end
  end

  defp forested?(board, island_type) do
    board
    |> Map.fetch!(island_type)
    |> Island.forested?()
  end

  defp overlaps_existing_island?(board, new_island_type, new_island) do
    Enum.any?(board, fn {island_type, island} ->
      island_type != new_island_type and Island.overlaps?(island, new_island)
    end)
  end
end
