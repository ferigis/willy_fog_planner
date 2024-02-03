defmodule WillyFog.Planner.Plans.Segment.Flight do
  @moduledoc """
  Encapsulates a Flight segment
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @fields ~w(origin destination starts_at arrives_at)a

  @primary_key false
  embedded_schema do
    field(:origin, WillyFog.Planner.Plans.Types.Iata)
    field(:destination, WillyFog.Planner.Plans.Types.Iata)
    field(:starts_at, :naive_datetime)
    field(:arrives_at, :time)
  end

  ## API

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = t, attrs) do
    t
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
