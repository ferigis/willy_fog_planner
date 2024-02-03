defmodule WillyFog.Planner.Plans do
  @moduledoc """
  Context module for dealing with plans
  """

  alias Ecto.Changeset
  alias WillyFog.Planner.Plans.{Plan, RawPlan, Trip}
  alias WillyFog.Planner.Plans.Segment

  @spec create_raw_plan(map) :: {:ok, RawPlan.t()} | {:error, Changeset.t()}
  def create_raw_plan(params) when is_map(params) do
    %RawPlan{}
    |> RawPlan.changeset(params)
    |> apply_changes()
  end

  @spec create_trip(map) :: {:ok, Trip.t()} | {:error, Changeset.t()}
  def create_trip(params) when is_map(params) do
    %Trip{}
    |> Trip.changeset(params)
    |> apply_changes()
  end

  @spec create_plan(map) :: {:ok, Plan.t()} | {:error, Changeset.t()}
  def create_plan(params) when is_map(params) do
    %Plan{}
    |> Plan.changeset(params)
    |> apply_changes()
  end

  @doc """
  This function gets a raw plan and process it. Generating as an output a real
  plan, split in trips.
  """
  @spec process_raw_plan(RawPlan.t()) :: Plan.t()
  def process_raw_plan(%RawPlan{} = raw_plan) do
    segments_sorted =
      Enum.sort_by(
        raw_plan.segments,
        &get_initial_datetime/1,
        &(NaiveDateTime.compare(&1, &2) != :gt)
      )

    trips = build_trips(segments_sorted, raw_plan.base)
    {:ok, plan} = create_plan(%{base: raw_plan.base})
    %Plan{plan | trips: trips}
  end

  ## Private functions

  defp apply_changes(%Changeset{valid?: false} = cs), do: {:error, cs}

  defp apply_changes(%Changeset{} = cs) do
    {:ok, Changeset.apply_changes(cs)}
  end

  defp get_initial_datetime(%Segment{type: "flight", flight: flight}), do: flight.starts_at
  defp get_initial_datetime(%Segment{type: "train", train: train}), do: train.starts_at

  defp get_initial_datetime(%Segment{type: "hotel", hotel: hotel}) do
    date_str = Date.to_iso8601(hotel.checkin) <> " 23:59:59"
    {:ok, ndt} = NaiveDateTime.from_iso8601(date_str)
    ndt
  end

  defp build_trips([segment | segments], base) do
    do_build_trips_segments(segments, [segment], [], base)
  end

  defp do_build_trips_segments([], current_trip_segments, trips, _) do
    trips ++ [build_trip(current_trip_segments)]
  end

  defp do_build_trips_segments([segment | segments], current_trip_segments, trips, base) do
    if start_new_trip?(segment, base) do
      do_build_trips_segments(
        segments,
        [segment],
        trips ++ [build_trip(current_trip_segments)],
        base
      )
    else
      do_build_trips_segments(segments, current_trip_segments ++ [segment], trips, base)
    end
  end

  defp start_new_trip?(segment, base) do
    case get_origin(segment) do
      ^base -> true
      _ -> false
    end
  end

  defp build_trip([segment | _] = segments) do
    origin = get_origin(segment)

    {:ok, trip} =
      create_trip(%{
        origin: origin,
        destinations: get_destinations(segments, origin)
      })

    %Trip{trip | segments: segments}
  end

  ## For train and flight we should calculate it with the arrival_at but
  ## for simplify code I use starts_at
  defp get_final_datetime(%Segment{type: "flight", flight: flight}), do: flight.starts_at
  defp get_final_datetime(%Segment{type: "train", train: train}), do: train.starts_at

  defp get_final_datetime(%Segment{type: "hotel", hotel: hotel}) do
    date_str = Date.to_iso8601(hotel.checkout) <> " 23:59:59"
    {:ok, ndt} = NaiveDateTime.from_iso8601(date_str)
    ndt
  end

  defp get_destinations([segment | segments], origin) do
    {_, destinations} =
      Enum.reduce(segments, {segment, [get_destination(segment)]}, fn s, {prev_segment, acc} ->
        if connection?(s, prev_segment) do
          # delete the last destination
          acc = acc |> Enum.reverse() |> tl()
          current_dest = get_destination(s)
          {s, Enum.reverse([current_dest | acc])}
        else
          current_dest = get_destination(s)
          {s, acc ++ [current_dest]}
        end
      end)

    destinations
    |> Enum.uniq()
    |> Enum.reject(&(&1 == origin))
  end

  defp connection?(%Segment{type: t1} = segment, %Segment{type: t2} = prev_segment)
       when t1 in ["flight", "train"] and t2 in ["flight", "train"] do
    # if the previous segment is flight or train and current one too, we check if
    # is a connection. This means less than 24 hours between both
    previous_date = get_final_datetime(prev_segment)

    segment
    |> get_initial_datetime()
    |> NaiveDateTime.diff(previous_date)
    |> Kernel./(60 * 60)
    |> Kernel.<(24)
  end

  defp connection?(_, _), do: false

  defp get_origin(%Segment{type: "flight", flight: flight}), do: flight.origin
  defp get_origin(%Segment{type: "train", train: train}), do: train.origin
  defp get_origin(%Segment{type: "hotel", hotel: hotel}), do: hotel.city

  defp get_destination(%Segment{type: "flight", flight: flight}), do: flight.destination
  defp get_destination(%Segment{type: "train", train: train}), do: train.destination
  defp get_destination(%Segment{type: "hotel", hotel: hotel}), do: hotel.city
end
