defmodule Reasoner.Plan do
  require Logger

  def select_handler(_, message_handlers, beliefs, :no_event), do: {:no_plan, []}
  def select_handler(_, message_handlers, beliefs, %{event_type: :received_message}=event) do
    do_select_handler(MessageHandlerSelection, message_handlers, beliefs, event)
  end

  def select_handler(plans, _, beliefs, event) do
    do_select_handler(PlanSelection, plans, beliefs, event)
  end

  defp do_select_handler([], _, _), do: {:no_plan, []}
  defp do_select_handler(selector, handler, beliefs, event) do
    Logger.info fn -> "\nAll plan rules:\n#{inspect(handler)}" end

    relavent_handlers = selector.relavent_handlers(handler, event)
    Logger.info fn -> "\nRelevant handler:\n#{inspect(relavent_handlers)}" end

    Logger.info fn -> "\nBeliefs:\n#{inspect(beliefs)}" end
    applicable_handlers = selector.applicable_handlers(relavent_handlers, beliefs)

    Logger.info fn -> "\nApplicable handler:\n#{inspect(applicable_handlers)}" end

    case select_current_plan(applicable_handlers) do
      {selected_plan, binding} ->
        Logger.info fn -> "\nSelected Plan:\n#{inspect(selected_plan)}" end
        Logger.info fn -> "\nNew Binding: #{inspect(binding)}" end

        {selected_plan, binding |> hd}
        _ ->
          Logger.info fn -> "\nNo applicable handler found" end
          {:no_plan, []}
    end
  end

  defp select_current_plan([]), do: []
  defp select_current_plan(applicable_handlers) do
    applicable_handlers |> hd
  end
end
