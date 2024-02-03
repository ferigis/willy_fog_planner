# Design

Some considerations:

- I consider a trip starts always from base city (SVQ in our example)
- The arrival hours misses the date, so I assume is the same day as the flight/train started

## First Steps

I have dealt with this exercise same way I would deal with a open source project for converting this kind of input data. Instead of converting the input in the output format directly I created an internal state in the midle. I have used Ecto (maybe too much for this but I wanted to take advantage of the cast/changeset power). I also used Timex for date's formatting.

## How the library works

The main module and entry point is [WillyFog.Planner](./lib/willy_fog/planner.ex). Here we define two functions:
- `parse/1` which receives a string and returns a ok tuple with a [Plan](./lib/willy_fog/planner/plans/plan.ex)
- `parse_file/1` which receives a path to a file and then calls internally to `parse/1`.

For example, lets try with this input:

```
BASED: SVQ

RESERVATION
SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10

RESERVATION
SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10

RESERVATION
SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10
SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50
```

First we need to load the library in our elixir IEX console (this is not an application).

```
iex -S mix
```

In the console we can run the library now

```elixir
iex(2)> WillyFog.Planner.parse input
{:ok,
 %WillyFog.Planner.Plans.Plan{
   base: "SVQ",
   trips: [
     %WillyFog.Planner.Plans.Trip{
       origin: "SVQ",
       destinations: ["BCN"],
       segments: [
         %WillyFog.Planner.Plans.Segment{
           type: "flight",
           flight: %WillyFog.Planner.Plans.Segment.Flight{
             origin: "SVQ",
             destination: "BCN",
             starts_at: ~N[2023-01-05 20:40:00],
             arrives_at: ~T[22:10:00]
           },
           train: nil,
           hotel: nil
         },
         %WillyFog.Planner.Plans.Segment{
           type: "hotel",
           flight: nil,
           train: nil,
           hotel: %WillyFog.Planner.Plans.Segment.Hotel{
             city: "BCN",
             checkin: ~D[2023-01-05],
             checkout: ~D[2023-01-10]
           }
         },
         %WillyFog.Planner.Plans.Segment{
           type: "flight",
           flight: %WillyFog.Planner.Plans.Segment.Flight{
             origin: "BCN",
             destination: "SVQ",
             starts_at: ~N[2023-01-10 10:30:00],
             arrives_at: ~T[11:50:00]
           },
           train: nil,
           hotel: nil
         }
       ]
     },
     %WillyFog.Planner.Plans.Trip{
       origin: "SVQ",
       destinations: ["BCN"],
       segments: [
         %WillyFog.Planner.Plans.Segment{
           type: "flight",
           flight: %WillyFog.Planner.Plans.Segment.Flight{
             origin: "SVQ",
             destination: "BCN",
             starts_at: ~N[2023-03-02 06:40:00],
             arrives_at: ~T[09:10:00]
           },
           train: nil,
           hotel: nil
         }
       ]
     }
   ]
 }}
```

Note that I am returning a Plan struct instead of the required output String. I have done this having maintainability in mind, this means, today maybe we want to return a simple text but maybe tomorrow we would need to send an email with the itinerary, or a csv, or store it in the db... So the Plan struct is our main model. For this I created the module [Formatter](./lib/willy_fog/planner/formatter.ex) which currently only supports the `simple_text/1` output.

Lets format the previous response:

```elixir
iex(4)> WillyFog.Planner.Formatter.simple_text result
"TRIP to BCN\nFlight from SVQ to BCN at 2023-01-05 20:40 to 22:10\nHotel at BCN on 2023-01-05 to 2023-01-10\nFlight from BCN to SVQ at 2023-01-10 10:30 to 11:50\n\nTRIP to BCN\nFlight from SVQ to BCN at 2023-03-02 06:40 to 09:10\n"
```

## Run a file

In the root of the project we have the required [input.txt](./input.txt) file. I have created an Elixir script for running it (check `/scripts` folder), you can run it with:

```
$ mix run scripts/read_input_txt.exs
"TRIP to BCN\nFlight from SVQ to BCN at 2023-01-05 20:40 to 22:10\nHotel at BCN on 2023-01-05 to 2023-01-10\nFlight from BCN to SVQ at 2023-01-10 10:30 to 11:50\n\nTRIP to MAD\nTrain from SVQ to MAD at 2023-02-15 09:30 to 11:00\nHotel at MAD on 2023-02-15 to 2023-02-17\nTrain from MAD to SVQ at 2023-02-17 17:00 to 19:30\n\nTRIP to NYC, BOS\nFlight from SVQ to BCN at 2023-03-02 06:40 to 09:10\nFlight from BCN to NYC at 2023-03-02 15:00 to 22:45\nFlight from NYC to BOS at 2023-03-06 08:00 to 09:25\n"
```

It is calling internally the functions defined before, you can check [this file](./scripts/read_input_txt.exs)

## Testing

In order to run tests you run
```
mix test
```

I also provided a more extended function

```
mix check
```

This add aditional checks like code format, credo, coverage and dialyzer. This function takes some time the first time we run it since the Dialyzer's PLTs has to be built.

## Further steps

Since this is a prototype I didn't pay too much attention to performance. In a real world scenario we would check the size of the inputs, if they were huge we will try to find a better solution for reading the data with streams in a lazy way instead of loading all in memory.
