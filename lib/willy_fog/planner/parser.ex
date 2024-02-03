defmodule WillyFog.Planner.Parser do
  @moduledoc """
  This module is in charge of converting inputs into maps.
  """

  @spec parse_string(String.t()) :: {:ok, map} | {:error, :invalid_format}
  def parse_string(str) when is_binary(str) do
    params =
      {str, %{segments: []}}
      |> extract_base()
      |> extract_segments()

    {:ok, params}
  catch
    ## in the real world we would make the error handling more descriptive
    error -> error
  end

  def parse_string(_), do: {:error, :invalid_format}

  ## Private functions

  defp extract_base({<<"BASED: ", base::binary-size(3), rest::binary>>, acc}) do
    acc = Map.put(acc, :base, base)
    rest = String.trim(rest)
    {rest, acc}
  end

  defp extract_base(_), do: throw_invalid_format()

  defp extract_segments({"", acc}), do: acc

  defp extract_segments({<<"RESERVATION", rest::binary>>, acc}) do
    rest = String.trim(rest)
    extract_segments({rest, acc})
  end

  defp extract_segments({<<"SEGMENT: ", rest::binary>>, acc}) do
    rest = String.trim(rest)
    extract_segments({rest, acc})
  end

  defp extract_segments(
         {<<"Flight ", origin::binary-size(3), " ", starts_at::binary-size(16), " -> ",
            destination::binary-size(3), " ", arrives_at::binary-size(5), rest::binary>>,
          %{segments: segments} = acc}
       ) do
    segment = %{
      type: "flight",
      flight: %{
        origin: origin,
        destination: destination,
        starts_at: starts_at,
        arrives_at: arrives_at
      }
    }

    acc = Map.put(acc, :segments, [segment | segments])
    rest = String.trim(rest)
    extract_segments({rest, acc})
  end

  defp extract_segments(
         {<<"Train ", origin::binary-size(3), " ", starts_at::binary-size(16), " -> ",
            destination::binary-size(3), " ", arrives_at::binary-size(5), rest::binary>>,
          %{segments: segments} = acc}
       ) do
    segment = %{
      type: "train",
      train: %{
        origin: origin,
        destination: destination,
        starts_at: starts_at,
        arrives_at: arrives_at
      }
    }

    acc = Map.put(acc, :segments, [segment | segments])
    rest = String.trim(rest)
    extract_segments({rest, acc})
  end

  defp extract_segments(
         {<<"Hotel ", city::binary-size(3), " ", checkin::binary-size(10), " -> ",
            checkout::binary-size(10), rest::binary>>, %{segments: segments} = acc}
       ) do
    segment = %{
      type: "hotel",
      hotel: %{
        city: city,
        checkin: checkin,
        checkout: checkout
      }
    }

    acc = Map.put(acc, :segments, [segment | segments])
    rest = String.trim(rest)
    extract_segments({rest, acc})
  end

  defp extract_segments(_), do: throw_invalid_format()

  @spec throw_invalid_format() :: no_return
  defp throw_invalid_format, do: throw({:error, :invalid_format})
end
