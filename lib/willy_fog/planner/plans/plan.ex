defmodule WillyFog.Planner.Plans.Plan do
  @moduledoc """
  Encapsulates a Plan
  """
  use Ecto.Schema

  alias WillyFog.Planner.Plans.Trip

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:base, WillyFog.Planner.Plans.Types.Iata)
    embeds_many(:trips, Trip)
  end

  ## API

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = t, attrs) do
    t
    |> cast(attrs, [:base])
    |> validate_required([:base])
    |> cast_embed(:trips)
  end

  @spec to_text(t) :: String.t()
  def to_text(%__MODULE__{} = plan) do
    Enum.map_join(plan.trips, "\n", &Trip.to_text/1)
  end
end
