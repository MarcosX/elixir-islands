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
      iex> Rules.check(Rules.new(), :add_player)
      {:ok, %Rules{state: :players_set, player1: :islands_not_set, player2: :islands_not_set}}

      iex> Rules.check(Rules.new(), :invalid_action)
      :error

  Positioning islands
      iex> rules = %{Rules.new() | state: :players_set}
      ...> Rules.check(rules, {:position_islands, :player1})
      {:ok, %Rules{state: :players_set, player1: :islands_not_set, player2: :islands_not_set}}

      iex> rules = %{Rules.new() | state: :players_set, player1: :islands_set}
      ...> Rules.check(rules, {:position_islands, :player1})
      :error

  Setting player islands
      iex> rules = %{Rules.new() | state: :players_set}
      ...> Rules.check(rules, {:set_islands, :player1})
      {:ok, %Rules{state: :players_set, player1: :islands_set, player2: :islands_not_set}}

      iex> rules = %{Rules.new() | state: :players_set}
      ...> {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      ...> Rules.check(rules, {:set_islands, :player2})
      {:ok, %Rules{state: :player1_turn, player1: :islands_set, player2: :islands_set}}
  """
  @spec check(Rules.t(), any) :: :error | {:ok, Rules.t()}
  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    case both_players_islands_set?(rules) do
      true -> {:ok, %Rules{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  def check(_state, _action), do: :error

  defp both_players_islands_set?(rules) do
    rules.player1 == :islands_set && rules.player2 == :islands_set
  end
end
