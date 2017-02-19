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
    is_top_atomic = Intention.is_top_atomic(intent)
    do_execute_intent(beliefs, intent, is_top_atomic)
  end

  defp do_execute_intent(beliefs, intent, true) do
    %{bindings: bindings, instructions: instructions, event: event} =
    Intention.top_exectuion(intent)
    new_intents = Intention.remove_top_intent(intent)

    res = do_execute_instructions(:no_op, instructions, beliefs, bindings, [], nil)

    case res do
      {:execution_error, instruction} ->
        {:execution_error, new_intents, instruction, event}
      :halt_agent ->
        :halt_agent
      {events, beliefs, _} ->
        {events, new_intents, beliefs}
    end
  end

  defp do_execute_intent(beliefs, intent, false) do
    {instruction, bindings, event, new_intent} = Intention.next_instruction(intent)

    {new_events, status, new_beliefs, new_binding} =
    execute_instruction(instruction, beliefs, bindings)

    new_intent = Intention.update_bindings(new_intent, new_binding)
    intent_after_execution_result(status, new_events, new_intent, new_beliefs, instruction, event)
  end

  defp do_execute_instructions(:halt_agent, _, _, _, _, _), do: :halt_agent
  defp do_execute_instructions(:cant_unify, _, _, _, _, instruction),
    do: {:execution_error, instruction}

  defp do_execute_instructions(_, [], beliefs, bindings, events, _),
   do: {events, beliefs, bindings}

  defp do_execute_instructions(status, [instruction| rest], beliefs, bindings, events, _) do
    {new_events, status, new_beliefs, new_binding} =
    execute_instruction(instruction, beliefs, bindings)
    do_execute_instructions(status, rest, new_beliefs, new_binding, events ++ new_events, instruction)
  end

  defp execute_instruction(instruction, beliefs, bindings) do
    Logger.info "Instruction to execute\n#{inspect(instruction)}"

    result = Executor.execute(instruction, beliefs, bindings)
    new_events = event_from_execution_result(result, instruction)
    {{status, new_beliefs}, new_binding} = result

    {new_events, status, new_beliefs, new_binding}
  end

  defp event_from_execution_result(result, instruction) do
    case result do
      {{:cant_unify, _}, _} -> nil
      {{:halt_agent, _}, _} -> nil

      {{:no_op, _}, _} -> []
      {{:already_added, _}, _} -> []
      {{:not_found, _}, _} -> []
      {{:action, _}, _} -> []

      {{:added, _}, binding} -> [Event.from_instruction(instruction, binding)]
      {{:removed, _}, binding} -> [Event.from_instruction(instruction, binding)]
      {{:no_change, _}, binding} -> [Event.from_instruction(instruction, binding)]
      {{:unified, _}, binding} -> [Event.from_instruction(instruction, binding)]

      {{[removed: removed, added: added], _}, _} ->
        removed_events = Enum.map(removed, fn bel -> Event.removed_belief(bel) end)
        added_events = Event.added_belief(added)
        removed_events ++ [added_events]
    end
  end

  defp intent_after_execution_result(status, events, intent, beliefs, instruction, event) do
    case status do
      :cant_unify ->
        {:execution_error, intent, instruction, event}
      :halt_agent ->
        :halt_agent
      _ ->
        {events, intent, beliefs}
    end
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
