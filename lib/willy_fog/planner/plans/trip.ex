defmodule WillyFog.Planner.Plans.Trip do
  @moduledoc """
  Encapsulates a Trip
  """
  use Ecto.Schema

  alias WillyFog.Planner.Plans.Segment

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @fields ~w(origin destinations)a

  @primary_key false
  embedded_schema do
    field(:origin, WillyFog.Planner.Plans.Types.Iata)
    field(:destinations, {:array, WillyFog.Planner.Plans.Types.Iata}, default: [])
    embeds_many(:segments, Segment)
  end

  ## API

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = t, attrs) do
    t
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> cast_embed(:segments)
  end

  @spec to_text(t) :: String.t()
  def to_text(%__MODULE__{} = trip) do
    segments = Enum.map_join(trip.segments, "", &Segment.to_text/1)

    """
    TRIP to #{Enum.join(trip.destinations, ", ")}
    """ <> segments
  end
end
