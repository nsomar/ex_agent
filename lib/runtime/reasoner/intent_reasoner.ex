defmodule Reasoner.Intent do
  require Logger

  def process_intents(intents, event, :no_plan, _) do
    {intents, event}
  end

  def process_intents(intents, event, selected_plan, bindings) do
    event_intent =
    %Intention{
      instructions: selected_plan.body,
      bindings: bindings,
      plan: selected_plan
    }

    {[event_intent| intents], event}
  end


  def select_intent([]), do: {:no_intent, []}
  def select_intent(intents) do
    [selected| rest] = intents
    Logger.info fn -> "\nSelected intent:\n#{inspect(selected)}" end
    {selected, rest}
  end


  def execute_intent(beliefs, :no_intent) do
    Logger.info "No intents left"
    {[], :no_intent, beliefs}
  end

  def execute_intent(beliefs, %{instructions: instructions, bindings: bindings}=intent) do
    [instruction| rest] = instructions

    Logger.info "Instruction to execute\n#{inspect(instruction)}"
    result = Executor.execute(instruction, beliefs, bindings)
    create_new_event_and_intent(intent, instruction, rest, result)
  end


  def build_new_intents(:no_intent, rest_intents),
  do: rest_intents

  def build_new_intents(%Intention{instructions: []}, rest_intents),
    do: rest_intents
  def build_new_intents(new_intent, rest_intents),
    do: [new_intent| rest_intents]


  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:added, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:already_added, beliefs}, binding}),
    do: create_new_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:removed, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:not_found, beliefs}, binding}),
    do: create_new_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:no_change, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:unified, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:action, beliefs}, binding}),
    do: create_new_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{[removed: removed, added: added], beliefs}, binding}) do
    removed_events = Enum.map(removed, fn bel -> Event.removed_belief(bel) end)
    added_events = Event.added_belief(added)

    {_, new_intent, beliefs} = create_new_intent(intent, instruction, rest_instructions, beliefs, binding)
    {removed_events ++ [added_events], new_intent, beliefs}
  end

  defp create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding) do
    event = Event.from_instruction(instruction, binding)
    new_intent = %{intent | bindings: binding, instructions: rest_instructions}
    {[event], new_intent, beliefs}
  end

  defp create_new_intent(intent, _, rest_instructions, beliefs, binding) do
    new_intent = %{intent | bindings: binding, instructions: rest_instructions}
    {[], new_intent, beliefs}
  end
end
