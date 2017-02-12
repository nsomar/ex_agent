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

  # def process_intentsX(intents, %Event{intents: nil}=event, selected_plan, bindings) do
  #   event_intent =
  #   %Intention{
  #     instructions: selected_plan.body,
  #     bindings: bindings,
  #     plan: selected_plan
  #   }

  #   event = %{event| intents: [event_intent]}
  #   {[event_intent| intents], event}
  # end

  # def process_intentsX(intents, %Event{intents: event_intents}=event, selected_plan, bindings) do
  #   event_intent =
  #   %Intention{
  #     instructions: selected_plan.body,
  #     bindings: bindings,
  #     plan: selected_plan
  #   }

  #   event_intents = [event_intent| event_intents]
  #   event = %{event| intents: event_intents}
  #   {event_intents ++ intents, event}
  # end

  def select_intent([]), do: {:no_intent, []}
  def select_intent(intents) do
    [selected| rest] = intents
    Logger.info fn -> "\nSelected intent:\n#{inspect(selected)}" end
    {selected, rest}
  end

  def execute_intent(_, :no_intent) do
    Logger.info "No intents left"
    {:no_event, :no_intent}
  end

  def execute_intent(beliefs, %{instructions: instructions, bindings: bindings}=intent) do
    [instruction| rest] = instructions

    Logger.info "Instruction to execute\n#{inspect(instruction)}"
    result = Executor.execute(instruction, beliefs, bindings)
    create_new_event_and_intent(intent, instruction, rest, result)
  end

  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:added, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)
  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:removed, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)
  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:no_change, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)
  defp create_new_event_and_intent(intent, instruction, rest_instructions, {{:unified, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, rest_instructions, beliefs, binding) do
    event = Event.from_instruction(instruction, binding)
    new_intent = %{intent | bindings: binding, instructions: rest_instructions}
    {event, new_intent, beliefs}
  end

  def build_new_intents(:no_intent, rest_intents),
  do: rest_intents

  def build_new_intents(%Intention{instructions: []}, rest_intents),
    do: rest_intents
  def build_new_intents(new_intent, rest_intents),
    do: [new_intent| rest_intents]
end
