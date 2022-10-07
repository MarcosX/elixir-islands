defmodule IslandsEngine.Rules do
  @moduledoc """
  `Rules` defines and validates what actions can happen in the game.
  """
  alias __MODULE__
  @type t :: %__MODULE__{}
  defstruct state: :initialized, player1: :islands_not_set, player2: :islands_not_set

  @doc """
  Returns a new rule engine

  ## Examples
      iex> Rules.new()
      %Rules{state: :initialized}
  """
  @spec new :: Rules.t()
  def(new, do: %Rules{})

  @doc """
  Updates the `rules` state based on the `action` passed.

  ## Examples
      iex> {:ok, rules} = Rules.check(Rules.new(), :add_player)
      {:ok, rules}

      iex> Rules.check(Rules.new(), :invalid_action)
      :error

  Setting player positions
      iex> rules = Rules.new()
      ...> rules = %{rules | state: :player_set}
      ...> {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
      ...> {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
      {:ok, rules}

      iex> rules = Rules.new()
      ...> rules = %{rules | state: :player_set}
      ...> rules = %{rules | player1: :islands_set}
      ...> Rules.check(rules, {:position_islands, :player1})
      :error
  """
  @spec check(Rules.t(), any) :: :error | {:ok, Rules.t()}
  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :player_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(_state, _action), do: :error
end
