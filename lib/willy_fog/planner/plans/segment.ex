defmodule WillyFog.Planner.Plans.Segment do
  @moduledoc """
  Encapsulates a Segment
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:type, :string)
    embeds_one(:flight, WillyFog.Planner.Plans.Segment.Flight)
    embeds_one(:train, WillyFog.Planner.Plans.Segment.Train)
    embeds_one(:hotel, WillyFog.Planner.Plans.Segment.Hotel)
  end

  ## API

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = t, attrs) do
    t
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> validate_inclusion(:type, ~w(flight train hotel))
    |> cast_segment_type()
  end

  # we could improve this using Elixir Protocols
  @spec to_text(t) :: String.t()
  def to_text(%__MODULE__{type: "flight", flight: flight}) do
    starts_at = Timex.format!(flight.starts_at, "%Y-%m-%d %H:%M", :strftime)
    arrives_at = Timex.format!(flight.arrives_at, "%H:%M", :strftime)

    """
    Flight from #{flight.origin} to #{flight.destination} at #{starts_at} to #{arrives_at}
    """
  end

  def to_text(%__MODULE__{type: "train", train: train}) do
    starts_at = Timex.format!(train.starts_at, "%Y-%m-%d %H:%M", :strftime)
    arrives_at = Timex.format!(train.arrives_at, "%H:%M", :strftime)

    """
    Train from #{train.origin} to #{train.destination} at #{starts_at} to #{arrives_at}
    """
  end

  def to_text(%__MODULE__{type: "hotel", hotel: hotel}) do
    """
    Hotel at #{hotel.city} on #{to_string(hotel.checkin)} to #{to_string(hotel.checkout)}
    """
  end

  ## Private functions

  defp cast_segment_type(cs) do
    case get_field(cs, :type) do
      "flight" -> cast_embed(cs, :flight)
      "train" -> cast_embed(cs, :train)
      "hotel" -> cast_embed(cs, :hotel)
      _ -> cs
    end
  end
end
