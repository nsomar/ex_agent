defmodule RelevantPlan do

  @spec relavent_plans([Rule.t], Event.t) :: [Rule.t]
  def relavent_plans(rules, event) do
    rules
    |> Enum.filter(fn rule -> is_same_event_type(rule, event) end)
    |> Enum.map(fn rule -> can_unify(rule, event) end)
    |> remove_ununified
  end

  @spec applicable_plans([{Rule.t, [atom]}], Event.t) :: [{Rule.t, [atom]}]
  def applicable_plans(rules_and_unifications, beleifs) do
    rules_and_unifications
    |> Enum.map(fn {rule, bindings} ->
      tests = rule.head.context.contexts
      function = rule.head.context.function
      unificaiton_result = Unifier.unify_list_with_binding(beleifs, tests, [bindings])
      {rule, unificaiton_result} |> IO.inspect
    end)
    |> remove_ununified
  end

  @spec is_same_event_type(Rule.t, Event.t) :: boolean
  defp is_same_event_type(rule, event) do
    plan_event_type = rule.head.trigger.event_type
    event_event_type = event.event_type
    plan_event_type == event_event_type
  end

  @spec can_unify(Rule.t, Event.t) :: boolean
  defp can_unify(rule, event) do
    plan_content = rule.head.trigger.content
    event_content = event.content
    {rule, Unifier.unify(event_content, plan_content)}
  end

  defp remove_ununified(rules_and_unifications) do
    rules_and_unifications
    |> Enum.filter(fn {_, unification_result} -> unification_result != :cant_unify end)
  end

end
