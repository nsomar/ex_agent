defmodule CommonHandlerSelection do

  @spec relavent_handlers([PlanHandler.t], Event.t) :: [Rule.t]
  def relavent_handlers(handlers, event) do
    handlers
    |> Enum.filter(fn handler -> handler_fit_for_event?(handler, event) end)
    |> Enum.map(fn handler -> unify_handler_and_event(handler, event) end)
    |> remove_ununified_results
  end

  @spec unify_handler_and_event(PlanHandler.t, Event.t) :: boolean
  defp unify_handler_and_event(handler, event) do
    handler_content = PlanHandler.trigger_content(handler)
    event_content = Event.content(event)
    {handler, Unifier.unify_tuples(event_content, handler_content)}
  end

  @spec applicable_handlers([{PlanHandler.t, [atom]}], Event.t) :: [{Rule.t, [atom]}]
  def applicable_handlers(rules_and_unifications, beleifs) do
    rules_and_unifications
    |> Enum.map(fn {handler, bindings} ->
      tests = handler.head.context.contexts

      unificaiton_result = Unifier.unify_list_with_binding(beleifs, tests, [bindings])
      passes_function = matches_function?(unificaiton_result, handler.head.context.function)
      {handler, unificaiton_result, passes_function}
    end)
    |> Enum.filter(fn {_, _, passes} -> passes end)
    |> Enum.map(fn {handler, result, _} -> {handler, result} end)
  end

  defp remove_ununified_results(rules_and_unifications) do
    rules_and_unifications
    |> Enum.filter(fn {_, unification_result} -> unification_result != :cant_unify end)
  end


  @spec handler_fit_for_event?(PlanHandler.t, Event.t) :: boolean
  defp handler_fit_for_event?(handler, %{event_type: :received_message}=event) do
    event.content.performative == PlanHandler.trigger_first_parameter(handler)
  end

  defp handler_fit_for_event?(rule, event) do
    event.event_type == PlanHandler.trigger_first_parameter(rule)
  end


  defp matches_function?([_], nil),
   do: true

  defp matches_function?([bindings], function),
   do: AstFunction.perform(function, bindings)

  defp matches_function?(_, _),
   do: false
end
