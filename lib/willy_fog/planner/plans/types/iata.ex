defmodule WillyFog.Planner.Plans.Types.Iata do
  @moduledoc """
  Custom ecto type for Iata.
  """
  use Ecto.Type
  def type, do: :string

  def cast(iata) when is_binary(iata) do
    case String.length(iata) do
      3 -> {:ok, iata}
      _ -> :error
    end
  end

  # Everything else is a failure though
  def cast(_), do: :error

  def load(iata) when is_binary(iata) do
    {:ok, iata}
  end

  def dump(iata) when is_binary(iata), do: {:ok, iata}
  def dump(_), do: :error
end
