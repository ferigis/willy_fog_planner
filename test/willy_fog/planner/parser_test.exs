defmodule WillyFog.Planner.ParserTest do
  use ExUnit.Case

  alias WillyFog.Planner.Parser

  @valid_input """
  BASED: SVQ

  RESERVATION
  SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10

  RESERVATION
  SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10
  """

  describe "parse_string/1" do
    test "ok" do
      assert {:ok, params} = Parser.parse_string(@valid_input)

      assert %{
               base: "SVQ",
               segments: [
                 %{
                   hotel: %{checkin: "2023-01-05", checkout: "2023-01-10", city: "BCN"},
                   type: "hotel"
                 },
                 %{
                   flight: %{
                     arrives_at: "09:10",
                     destination: "BCN",
                     origin: "SVQ",
                     starts_at: "2023-03-02 06:40"
                   },
                   type: "flight"
                 }
               ]
             } == params
    end

    test "error: invalid format" do
      assert {:error, :invalid_format} = Parser.parse_string(@valid_input <> "Z")
    end
  end
end
