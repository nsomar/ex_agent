require IEx

defmodule Reasoner do
  require Logger

  def run_loop(agent) do
    reason_cycle(agent)
  end

  def reason_cycle(agent) do
    agent_state = ExAgent.Mod.agent_state(agent)
    {_, new_agent_state} = reason(agent_state)
    ExAgent.Mod.set_agent_state(agent, new_agent_state)
  end

  def reason(%AgentState{
              messages: messages,
              events: events,
              beliefs: beliefs,
              plan_rules: plan_rules,
              message_handlers: message_handlers,
              recovery_handlers: recovery_handlers,
              intents: intents}=agent_state) do
    Logger.info "Reasoning Cycle Start"
    res = reason(agent_state, beliefs, plan_rules, message_handlers, recovery_handlers, events, messages, intents)
    Logger.info "Reasoning Cycle End"
    res
  end

  def reason(agent_state, beliefs, plan_rules, message_handlers, recovery_handlers, events, messages, intents) do
    message_event = Reasoner.Message.process_messages(messages)
    all_events = Reasoner.Event.merge_events(message_event, events)
    {event, rest_events} = Reasoner.Event.select_event(all_events)

    with {:ok, plan, binding} <- Reasoner.Plan.select_handler(plan_rules, message_handlers, beliefs, event),
         {:ok, new_intents} <- Reasoner.Intent.process_intents(intents, event, plan, binding),
         {:ok, selected_intent, rest_intents} <- Reasoner.Intent.select_intent(new_intents),
         {:ok, new_event, new_intent, new_beliefs} <- Reasoner.Intent.execute_intent(beliefs, selected_intent) do
      new_state = Reasoner.AgentState.update_state(agent_state, new_event, rest_events, new_intent, rest_intents, new_beliefs, [])
      {:changed, new_state}
    else
      :no_intent when event != :no_event ->
        log_event_removed(event, rest_events)
        {:changed, Reasoner.AgentState.update_agent_events(agent_state, rest_events)}

      :no_intent ->
        Logger.info "No intents left, No Events left"
        {:not_changed, agent_state}

      :halt_agent ->
        Logger.info "Halting agent received"
        {:halt_agent, agent_state}

      {:execution_error, failing_intent, failing_instruction, failing_event} ->
        log_failing_instruction(failing_instruction, failing_event)
        select_recovery_plan(agent_state, beliefs, recovery_handlers,
                             events, failing_event, intents, failing_intent)

      unexpected ->
        Logger.info "Unexpected result received\n#{unexpected}"
    end
  end

  def select_recovery_plan(agent_state, beliefs, recovery_handlers, events, failing_event, intents, failing_intent) do
    Logger.info "Selecting recovery plan"
    new_events = Enum.filter(events, fn event -> event != failing_event end)
    new_intents = Enum.filter(intents, fn intent -> intent != failing_intent end)

    with {:ok, plan, binding} <- Reasoner.Plan.select_recovery_handler(recovery_handlers, beliefs, failing_event),
         {:ok, [new_intent]} <- Reasoner.Intent.create_intent(failing_event, plan, binding, true, []) do
          Logger.info "Recovery plan found\n#{inspect(Intention.top_plan(new_intent))}"
          new_state = Reasoner.AgentState.update_state(agent_state, :no_event, new_events,
                                                       new_intent, new_intents, beliefs, [])
          {:recovery_added, new_state}
    else
      :no_intent ->
        Logger.info "No recovery plan found for failing event\n#{inspect(failing_event)}"
        new_state = Reasoner.AgentState.update_state(agent_state, :no_event, new_events,
                                                     :no_intent, new_intents, beliefs, [])
        {:no_recovery, new_state}
    end
  end

  ##########################################################################################
  # Logging
  ##########################################################################################
  defp log_failing_instruction(failing_instruction, failing_event) do
    Logger.info """
    Error executing
    #{inspect(failing_instruction)}
    For event
    #{inspect(failing_event)}
    """
  end

  defp log_event_removed(event, rest) do
    Logger.info """
    No intents left. Event removed
    #{inspect(event)}
    Rest events
    #{inspect(rest)}
    """
  end

end
