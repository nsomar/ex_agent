defmodule MessageHandlerSelection do

  @spec relavent_handlers([MessageHandler.t], Event.t) :: [Rule.t]
  def relavent_handlers(handlers, event) do
    handlers
    |> CommonHandlerSelection.relavent_handlers(event)
    |> merge_sender(event)
  end

  @spec applicable_handlers([{MessageHandler.t, [atom]}], Event.t) :: [{Rule.t, [atom]}]
  def applicable_handlers(rules_and_unifications, beleifs) do
    CommonHandlerSelection.applicable_handlers(rules_and_unifications, beleifs)
  end

  defp merge_sender(rules_and_unifications, %{content: %{from: from}}) do
    rules_and_unifications
    |> Enum.map(fn {handler, unificaiton_result} ->
      {handler, unificaiton_result ++ [{handler.head.sender, from}]}
    end)
  end

end
