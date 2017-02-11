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

  def execute_intent(agent_state, :no_intent) do
    Logger.info "No intents left"
    {:no_event, :no_intent}
  end

  def execute_intent(agent_state, %{instructions: instructions, bindings: bindings}=intent) do
    [instruction| rest] = instructions

    "ABC\n#{inspect(instruction)}" |> IO.inspect
    new_bindings = Executor.execute(instruction, agent_state, bindings)

    event = Event.from_instruction(instruction, new_bindings)
    new_intent = %{intent | instructions: rest, bindings: new_bindings}
    {event, new_intent}
  end

  def build_new_intents(:no_intent, rest_intents),
  do: rest_intents

  def build_new_intents(%Intention{instructions: []}, rest_intents),
    do: rest_intents
  def build_new_intents(new_intent, rest_intents),
    do: [new_intent| rest_intents]
end
