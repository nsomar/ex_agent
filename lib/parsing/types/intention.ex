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

  def update_bindings(%Intention{executions: []}=intent, bindings), do: intent
  def update_bindings(%Intention{executions: [top | rest]}=intent, bindings) do
    new_top = %{top | bindings: bindings}
    %{intent | executions: [new_top | rest]}
  end

  def next_instruction(%Intention{executions: [current | rest]}=intent) do
    {instruction, binding, event, execution} = IntentionExecution.next_instruction(current)

    new_executions = build_new_executions(execution, rest)
    new_intent = build_new_intent(intent, new_executions)

    {instruction, binding, event, new_intent}
  end

  def top_event(%Intention{executions: [current | rest]}=intent), do: current.event

  def top_plan(%Intention{executions: [current | rest]}=intent), do: current.plan

  defp build_new_executions(%IntentionExecution{instructions: []}=current, rest), do: rest
  defp build_new_executions(current, rest), do: [current | rest]

  # defp build_new_intent(intent, []), do: :no_intent
  # defp build_new_intent(intent, []), do: :no_intent
  defp build_new_intent(intent, executions), do: %{intent | executions: executions}

end
