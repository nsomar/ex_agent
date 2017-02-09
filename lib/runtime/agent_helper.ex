defmodule AgentHelper do
  require Logger

  def set_initial_as_events(agent, initial) do
    initial
    |> Enum.map(&(Event.from_instruction(&1, [])))
    |> Enum.map(&(EXAgent.add_event(agent, &1)))

    Logger.info "\nAdded initial beliefs/goals as events"
  end

  def add_plan_rules(agent, plans) do
    plans
    |> Enum.map(fn rule ->
      EXAgent.add_plan_rule(agent, rule)
    end)
  end
end
