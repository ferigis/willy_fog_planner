defmodule WillyFog.Planner.Plans.RawPlan do
  @moduledoc """
  Encapsulates a RawPlan. This is a plan with only segments, no trips or order.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:base, WillyFog.Planner.Plans.Types.Iata)
    embeds_many(:segments, WillyFog.Planner.Plans.Segment)
  end

  ## API

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = t, attrs) do
    t
    |> cast(attrs, [:base])
    |> validate_required([:base])
    |> cast_embed(:segments)
  end
end
