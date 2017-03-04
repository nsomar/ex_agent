defmodule IntentionExecution do
  defstruct [:instructions, :bindings, :plan, :event]

  def create(instructions, event, binding, plan) do
    %IntentionExecution{
      event: event,
      instructions: instructions,
      bindings: binding,
      plan: plan
    }
  end

  def next_instruction(%IntentionExecution{instructions: [instruction| rest], bindings: bindings, event: event}=execution) do
    new_execution = %{execution | instructions: rest}
    {instruction, bindings, event, new_execution}
  end
end

defmodule Intention do
  defstruct [:executions]

  def create(instructions, event \\ nil, binding \\ [], plan \\ nil) do
    %Intention{
      executions: [IntentionExecution.create(instructions, event, binding, plan)]
    }
  end

  def push(%Intention{executions: executions}=intent, instructions, event, binding \\ [], plan \\ nil) do
    new_execution = IntentionExecution.create(instructions, event, binding, plan)
    %{intent | executions: [new_execution | executions]}
  end

  def has_instructions?(intent) do
    case intent do
      %Intention{executions: []} ->
        false
      %Intention{executions: [%IntentionExecution{instructions: []}]} ->
        false
      _ ->
        true
    end
  end

  def update_bindings(%Intention{executions: []}=intent, _), do: intent
  def update_bindings(%Intention{executions: [top | rest]}=intent, bindings) do
    new_top = %{top | bindings: bindings}
    %{intent | executions: [new_top | rest]}
  end

  def next_instruction(%Intention{executions: [current | rest]}=intent) do
    {instruction, binding, event, execution} = IntentionExecution.next_instruction(current)
    # is it for_each
    # update the execution to add the new goals
    # return the first of them

    new_executions = build_new_executions(execution, rest)
    new_intent = build_new_intent(intent, new_executions)

    {instruction, binding, event, new_intent}
  end

  def is_top_atomic(%Intention{executions: [%IntentionExecution{plan: nil} | _]}),
    do: false
  def is_top_atomic(%Intention{executions: [%IntentionExecution{plan: plan} | _]}),
    do: plan.atomic

  def top_exectuion(%Intention{executions: [current| _]}) do
    current
  end

  def remove_top_intent(%Intention{executions: []}=intent), do: intent
  def remove_top_intent(%Intention{executions: [_| rest]}=intent),
    do: %{intent| executions: rest}

  def top_event(%Intention{executions: [current | _]}), do: current.event

  def top_plan(%Intention{executions: [current | _]}), do: current.plan

  def event_creates_new_intent?(%{event_type: :added_goal}), do: false
  def event_creates_new_intent?(_), do: true

  defp build_new_executions(%IntentionExecution{instructions: []}, rest), do: rest
  defp build_new_executions(current, rest), do: [current | rest]

  # defp build_new_intent(intent, []), do: :no_intent
  # defp build_new_intent(intent, []), do: :no_intent
  defp build_new_intent(intent, executions), do: %{intent | executions: executions}

end
