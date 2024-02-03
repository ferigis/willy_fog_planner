defmodule WillyFog.Planner.Formatter do
  @moduledoc """
  This module is in charge of formatting plans. Currently only simple text is supported,
  but this is place for more formats like csv, html, markdown...
  """

  alias WillyFog.Planner.Plans.Plan

  @spec simple_text(Plan.t()) :: String.t()
  def simple_text(%Plan{} = plan) do
    Plan.to_text(plan)
  end
end
