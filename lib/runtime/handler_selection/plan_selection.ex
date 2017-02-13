defmodule PlanSelection do

  @spec relavent_plans([Rule.t], Event.t) :: [Rule.t]
  def relavent_plans(rules, event) do
    CommonHandlerSelection.relavent_handlers(rules, event)
  end

  @spec applicable_plans([{Rule.t, [atom]}], Event.t) :: [{Rule.t, [atom]}]
  def applicable_plans(rules_and_unifications, beleifs) do
    CommonHandlerSelection.applicable_handlers(rules_and_unifications, beleifs)
  end

end
