defmodule Reasoner.Intent do
  require Logger

  def process_intents(intents, event, :no_plan, _) do
    {intents, event}
  end

  def process_intents(intents, event, selected_plan, bindings) do
    should_create = Intention.event_creates_new_intent?(event)
    {:ok, new_intents} = create_intent(event, selected_plan, bindings, should_create, intents)
    {new_intents, event}
  end


  def create_intent(event, :no_plan, _, _, _) do
    Logger.info "Intent was no created since no plan was received for event\n#{inspect(event)}"
    :no_intent
  end

  def create_intent(event, plan, bindings, false, []) do
    create_intent(event, plan, bindings, true, [])
  end

  def create_intent(event, plan, bindings, false, [top| rest]) do
    new_intent = Intention.push(top, plan.body, event, bindings, plan)
    new_intents = [new_intent | rest]
    log_intent_creation(new_intent, event, false)
    {:ok, new_intents}
  end

  def create_intent(event, plan, bindings, true, intents) do
    new_intent = Intention.create(plan.body, event, bindings, plan)
    new_intents = [new_intent | intents]
    log_intent_creation(new_intent, event, true)
    {:ok, new_intents}
  end


  def select_intent([]), do: {:no_intent, []}
  def select_intent(intents) do
    [selected| rest] = intents
    Logger.info fn -> "\nSelected intent:\n#{inspect(selected)}" end
    {selected, rest}
  end

  ##########################################################################################
  # Intent execution
  ##########################################################################################

  def execute_intent(_, :no_intent) do
    :no_intent
  end

  def execute_intent(beliefs, intent) do
    {instruction, bindings, event, new_intent} = Intention.next_instruction(intent)

    Logger.info "Instruction to execute\n#{inspect(instruction)}"
    result = Executor.execute(instruction, beliefs, bindings)
    create_new_event_and_intent(new_intent, instruction, event, result)
  end

  defp create_new_event_and_intent(intent, instruction, event, {{:cant_unify, _}, _}),
    do: {:execution_error, intent, instruction, event}

  defp create_new_event_and_intent(_, _, _, {{:halt_agent, _}, _}),
    do: :halt_agent

  defp create_new_event_and_intent(intent, instruction, _, {{:no_op, beliefs}, binding}),
    do: create_new_intent(intent, instruction, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, event, {{:added, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, event, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, _, {{:already_added, beliefs}, binding}),
    do: create_new_intent(intent, instruction, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, event, {{:removed, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, event, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, _, {{:not_found, beliefs}, binding}),
    do: create_new_intent(intent, instruction, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, event, {{:no_change, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, event, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, event, {{:unified, beliefs}, binding}),
    do: create_new_event_and_intent(intent, instruction, event, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, _, {{:action, beliefs}, binding}),
    do: create_new_intent(intent, instruction, beliefs, binding)

  defp create_new_event_and_intent(intent, instruction, _, {{[removed: removed, added: added], beliefs}, binding}) do
    removed_events = Enum.map(removed, fn bel -> Event.removed_belief(bel) end)
    added_events = Event.added_belief(added)

    {_, new_intent, beliefs} = create_new_intent(intent, instruction, beliefs, binding)
    {removed_events ++ [added_events], new_intent, beliefs}
  end

  defp create_new_event_and_intent(intent, instruction, _, beliefs, binding) do
    event = Event.from_instruction(instruction, binding)
    new_intent = Intention.update_bindings(intent, binding)
    {[event], new_intent, beliefs}
  end

  defp create_new_intent(intent, _, beliefs, binding) do
    new_intent = Intention.update_bindings(intent, binding)
    {[], new_intent, beliefs}
  end

  ##########################################################################################
  # Building intents
  ##########################################################################################

  def build_new_intents(:no_intent, rest_intents),
    do: rest_intents
  def build_new_intents(%Intention{executions: []}, rest_intents),
    do: rest_intents
  def build_new_intents(%Intention{executions: [%IntentionExecution{instructions: []}]}, rest_intents),
    do: rest_intents
  def build_new_intents(new_intent, rest_intents),
    do: rest_intents ++ [new_intent]

  ##########################################################################################
  # Logging
  ##########################################################################################
  defp log_intent_creation(intent, event, false) do
    Logger.info """
    Intent execution was pushed on top intent
    #{inspect(intent)}
    For event
    #{inspect(event)}
    """
  end

  defp log_intent_creation(intent, event, true) do
    Logger.info """
    New intent created
    #{inspect(intent)}
    For event
    #{inspect(event)}
    """
  end

end
