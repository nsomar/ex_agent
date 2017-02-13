defmodule PlanSelection do

  @spec relavent_handlers([Rule.t], Event.t) :: [Rule.t]
  def relavent_handlers(rules, event) do
    CommonHandlerSelection.relavent_handlers(rules, event)
  end

  @spec applicable_handlers([{Rule.t, [atom]}], Event.t) :: [{Rule.t, [atom]}]
  def applicable_handlers(rules_and_unifications, beleifs) do
    CommonHandlerSelection.applicable_handlers(rules_and_unifications, beleifs)
  end

end
