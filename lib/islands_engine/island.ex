defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  @doc """
  Creates a new island of `type` starting at the `upper_left` coordinate

  ## Examples
      iex> Island.new(:square, %Coordinate{row: 1, col: 1})
      {:ok, %Island{
        coordinates: MapSet.new(
          [%Coordinate{row: 1, col: 1},
          %Coordinate{row: 2, col: 1},
          %Coordinate{row: 1, col: 2},
          %Coordinate{row: 2, col: 2}]),
        hit_coordinates: %MapSet{}}}
  """
  @type island_type :: :square | :atoll | :dot | :l_shape | :s_shape
  @spec new(island_type, %Coordinate{}) :: %Island{}
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  @doc """
  Checks if `new_island` overlaps with `existing_island`

  ## Examples
      iex> {:ok, l_island} = Island.new(:l_shape, %Coordinate{row: 5, col: 5})
      ...> {:ok, square_island} = Island.new(:square, %Coordinate{row: 1, col: 1})
      ...> Island.overlaps?(l_island, square_island)
      false

      iex> {:ok, l_island} = Island.new(:l_shape, %Coordinate{row: 1, col: 1})
      ...> {:ok, square_island} = Island.new(:square, %Coordinate{row: 1, col: 1})
      ...> Island.overlaps?(l_island, square_island)
      true
  """
  @spec overlaps?(%Island{}, %Island{}) :: boolean
  def overlaps?(existing_island, new_island) do
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
  end

  @doc """
  Guesses if a `coordinate` hits the `island`

  ## Example
      iex> {:ok, island} = Island.new(:dot, %Coordinate{row: 1, col: 1})
      ...> Island.guess(island, %Coordinate{row: 1, col: 1})
      {:hit, %Island{
        coordinates: MapSet.new([%Coordinate{row: 1, col: 1}]),
        hit_coordinates: MapSet.new([%Coordinate{row: 1, col: 1}])}}

      iex> {:ok, island} = Island.new(:dot, %Coordinate{row: 1, col: 1})
      ...> Island.guess(island, %Coordinate{row: 2, col: 2})
      :miss
  """
  @spec guess(%Island{}, %Coordinate{}) :: :miss | {:hit, %Island{}}
  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  @doc """
  Checks all coordinates of `island` have been hit

  ## Example
      iex> {:ok, island} = Island.new(:dot, %Coordinate{row: 1, col: 1})
      ...> Island.forested?(island)
      false

      iex> {:ok, island} = Island.new(:dot, %Coordinate{row: 1, col: 1})
      ...> {:hit, island} = Island.guess(island, %Coordinate{row: 1, col: 1})
      ...> Island.forested?(island)
      true
  """
  @spec forested?(%Island{}) :: boolean
  def forested?(island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  @doc """
  Returns all types of islands

  ## Examples
      iex> Island.types()
      [:atoll, :dot, :l_shape, :s_shape, :square]
  """
  @spec types() :: [:atoll | :dot | :l_shape | :s_shape | :square]
  def types(), do: [:atoll, :dot, :l_shape, :s_shape, :square]

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, %Coordinate{row: upper_left_row, col: upper_left_col}) do
    Enum.reduce_while(offsets, MapSet.new(), fn {row_offset, col_offset}, coordinates ->
      case Coordinate.new(upper_left_row + row_offset, upper_left_col + col_offset) do
        {:ok, coordinate} ->
          {:cont, MapSet.put(coordinates, coordinate)}

        {:error, :invalid_coordinate} ->
          {:halt, {:error, :invalid_island_position}}
      end
    end)
  end
end
