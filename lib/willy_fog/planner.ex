defmodule WillyFog.Planner do
  @moduledoc """
  This is the entry point for this library. We support 2 ways to parse the data, pure String or
  a file path.
  """

  alias WillyFog.Planner.{Parser, Plans}
  alias WillyFog.Planner.Plans.{Plan, RawPlan}

  @spec parse(String.t()) :: {:ok, Plan.t()} | {:error, Ecto.Changeset.t() | :invalid_format}
  def parse(str) when is_binary(str) do
    with {:ok, %{} = plan_params} <- Parser.parse_string(str),
         {:ok, %RawPlan{} = raw_plan} <- Plans.create_raw_plan(plan_params) do
      plan = Plans.process_raw_plan(raw_plan)
      {:ok, plan}
    end
  end

  @spec parse_file(binary) :: {:ok, Plan.t()} | {:error, Ecto.Changeset.t() | atom}
  def parse_file(path) when is_binary(path) do
    case File.read(path) do
      {:ok, content} ->
        parse(content)

      error ->
        error
    end
  end
end
