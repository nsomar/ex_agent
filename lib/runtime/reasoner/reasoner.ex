require IEx

defmodule Reasoner do
  require Logger

  def run_loop(agent) do
    reason_cycle(agent)
  end

  def reason_cycle(agent) do
    agent_state = ExAgent.agent_state(agent)
    {update, new_agent_state} = reason(agent_state)
    ExAgent.set_agent_state(agent, new_agent_state)
  end

  def reason(
             %AgentState{
              messages: messages,
              events: events,
              beliefs: beliefs,
              plan_rules: plan_rules,
              message_handlers: message_handlers,
              intents: intents}=agent_state) do
    Logger.info "Reasoning Cycle Start"
    res = reason(agent_state, beliefs, plan_rules, message_handlers, events, messages, intents)
    Logger.info "Reasoning Cycle End"
    res
  end

  def reason(agent_state, beliefs, plan_rules, message_handlers, events, messages, intents) do
    with message_event <- Reasoner.Message.process_messages(messages),
         all_events <- Reasoner.Event.merge_events(message_event, events),
         {event, rest_events} <- Reasoner.Event.select_event(all_events),
         {plan, binding} <- Reasoner.Plan.select_handler(plan_rules, message_handlers, beliefs, event),
         {new_intents, new_event} <- Reasoner.Intent.process_intents(intents, event, plan, binding),
         {selected_intent, rest_intents} <- Reasoner.Intent.select_intent(new_intents),
         {new_event, new_intent, new_beliefs} <- Reasoner.Intent.execute_intent(beliefs, selected_intent) do
      new_state = Reasoner.AgentState.update_state(agent_state, new_event, rest_events, new_intent, rest_intents, new_beliefs, [])
      {:changed, new_state}
    else
      :no_intent ->
        Logger.info "No intents left"
        {:not_changed, agent_state}
      _ -> 1 |> IO.inspect
    end
  end

end
