defmodule Reasoner do
  require Logger

  def reason(agent, instruction, binding) do
    event = event_for_instruction(instruction, binding)
    rules = EXAgent.plan_rules(agent)

    beliefs =
      agent
      |> EXAgent.belief_base
      |> BeliefBase.beliefs

    Logger.info fn -> "\nEvent:\n#{inspect(event)}" end
    Logger.info fn -> "\nAll plan rules:\n#{inspect(rules)}" end

    relavent_plans = PlanSelection.relavent_plans(rules, event)
    Logger.info fn -> "\nRelevant plans:\n#{inspect(relavent_plans)}" end

    Logger.info fn -> "\nBeliefs:\n#{inspect(beliefs)}" end
    applicable_plans = PlanSelection.applicable_plans(relavent_plans, beliefs)

    Logger.info fn -> "\nApplicable plans:\n#{inspect(applicable_plans)}" end

    {selected_plan, new_binding} = applicable_plans |> hd
    Logger.info fn -> "\nSelected Plan:\n#{inspect(selected_plan)}" end
    Logger.info fn -> "\nNew Binding: #{inspect(new_binding)}" end

    selected_plan.body |> IO.inspect
  end

  def event_for_instruction(%AddBelief{}=instruction, binding) do
    Event.added_belief(instruction |> EventContent.content(binding))
  end

  def event_for_instruction(%RemoveBelief{}=instruction, binding) do
    Event.removed_belief(instruction |> EventContent.content(binding))
  end

  def event_for_instruction(%AchieveGoal{}=instruction, binding) do
    Event.added_goal(instruction |> EventContent.content(binding))
  end

end
