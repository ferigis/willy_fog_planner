alias WillyFog.Planner
alias WillyFog.Planner.Formatter
alias WillyFog.Planner.Plans.Plan

{:ok, %Plan{} = plan} = Planner.parse_file("input.txt")
result = Formatter.simple_text(plan)

IO.inspect result
