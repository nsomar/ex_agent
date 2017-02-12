defmodule MessageHandlerSelection do

  @spec relavent_handlers([MessageHandler.t], Event.t) :: [Rule.t]
  def relavent_handlers(handlers, event) do
    handlers
    |> Enum.filter(fn handler -> is_same_performative(handler, event) end)
    |> Enum.map(fn handler -> can_unify(handler, event) end)
    |> remove_ununified
    |> merge_sender(event)
  end

  @spec applicable_handlers([{MessageHandler.t, [atom]}], Event.t) :: [{Rule.t, [atom]}]
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

  defp matches_function?([_], nil),
   do: true

  defp matches_function?([bindings], function),
   do: AstFunction.perform(function, bindings)

  defp matches_function?(_, _),
   do: false

  @spec is_same_performative(MessageHandler.t, Event.t) :: boolean
  defp is_same_performative(handler, event) do
    handler_performative = handler.head.trigger.performative
    event_performative = event.content.performative
    handler_performative == event_performative
  end

  @spec can_unify(MessageHandler.t, Event.t) :: boolean
  defp can_unify(handler, event) do
    handler_message = handler.head.trigger.message
    event_content = Message.message(event.content)

    {handler, Unifier.unify_tuples(event_content, handler_message)}
  end

  defp remove_ununified(rules_and_unifications) do
    rules_and_unifications
    |> Enum.filter(fn {_, unification_result} -> unification_result != :cant_unify end)
  end

  defp merge_sender(rules_and_unifications, %{content: %{from: from}}) do
    rules_and_unifications
    |> Enum.map(fn {handler, unificaiton_result} ->
      {handler, unificaiton_result ++ [{handler.head.sender, from}]}
    end)
  end

end
