defmodule WillyFog.PlannerTest do
  use ExUnit.Case

  alias WillyFog.Planner
  alias WillyFog.Planner.Plans.{Plan, Segment, Trip}
  alias WillyFog.Planner.Plans.Segment.Flight

  describe "parse/1" do
    test "simple flight reservation" do
      input = """
      BASED: SVQ

      RESERVATION
      SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10
      """

      assert {:ok, %Plan{} = plan} = Planner.parse(input)

      assert %Plan{
               base: "SVQ",
               trips: [
                 %Trip{
                   origin: "SVQ",
                   destinations: ["BCN"],
                   segments: [
                     %Segment{
                       type: "flight",
                       flight: %Flight{
                         origin: "SVQ",
                         destination: "BCN",
                         starts_at: ~N[2023-03-02 06:40:00],
                         arrives_at: ~T[09:10:00]
                       }
                     }
                   ]
                 }
               ]
             } == plan
    end

    test "wrong input" do
      assert {:error, :invalid_format} = Planner.parse("hiiii")
    end
  end

  describe "parse_file/1" do
    test "ok" do
      assert {:ok, %Plan{base: "SVQ", trips: [_, _, _]}} = Planner.parse_file("input.txt")
    end

    test "wrong file" do
      assert {:error, :enoent} = Planner.parse_file("wrong.txt")
    end
  end
end
