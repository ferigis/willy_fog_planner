defmodule WillyFog.Planner.Plans.Segment.Hotel do
  @moduledoc """
  Encapsulates a Hotel segment
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @fields ~w(city checkin checkout)a

  @primary_key false
  embedded_schema do
    field(:city, WillyFog.Planner.Plans.Types.Iata)
    field(:checkin, :date)
    field(:checkout, :date)
  end

  ## API

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = t, attrs) do
    t
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
