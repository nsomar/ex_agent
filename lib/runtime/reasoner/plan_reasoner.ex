defmodule Reasoner.Plan do
  require Logger

  def select_plan(_, _, :no_event), do: {:no_plan, []}
  def select_plan([], _, _), do: {:no_plan, []}
  def select_plan(plans, beliefs, event) do
    Logger.info fn -> "\nAll plan rules:\n#{inspect(plans)}" end

    relavent_plans = PlanSelection.relavent_plans(plans, event)
    Logger.info fn -> "\nRelevant plans:\n#{inspect(relavent_plans)}" end

    Logger.info fn -> "\nBeliefs:\n#{inspect(beliefs)}" end
    applicable_plans = PlanSelection.applicable_plans(relavent_plans, beliefs)

    Logger.info fn -> "\nApplicable plans:\n#{inspect(applicable_plans)}" end

    case select_current_plan(applicable_plans) do
      {selected_plan, binding} ->
        Logger.info fn -> "\nSelected Plan:\n#{inspect(selected_plan)}" end
        Logger.info fn -> "\nNew Binding: #{inspect(binding)}" end

        {selected_plan, binding |> hd}
        _ ->
          Logger.info fn -> "\nNo applicable plans found" end
          {:no_plans, []}
    end
  end

  defp select_current_plan([]), do: []
  defp select_current_plan(applicable_plans) do
    applicable_plans |> hd
  end
end
