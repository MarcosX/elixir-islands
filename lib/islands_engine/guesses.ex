defmodule IslandsEngine.Guesses do
  alias IslandsEngine.{Guesses, Coordinate}

  @enforce_keys [:hits, :misses]
  defstruct hits: MapSet.new(), misses: MapSet.new()

  @spec new() :: %Guesses{}
  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @doc """
  Adds a `coordinate` as a `:hit` or `:miss` guess to `guesses`

  ## Examples
      iex> Guesses.add(Guesses.new(), :hit, %Coordinate{row: 1, col: 2})
      %Guesses{hits: MapSet.new([%Coordinate{row: 1, col: 2}]), misses: %MapSet{}}

      iex> Guesses.add(Guesses.new(), :miss, %Coordinate{row: 1, col: 2})
      %Guesses{hits: %MapSet{}, misses: MapSet.new([%Coordinate{row: 1, col: 2}])}
  """
  @spec add(%Guesses{}, :hit | :miss, %Coordinate{}) :: %Guesses{}
  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end
