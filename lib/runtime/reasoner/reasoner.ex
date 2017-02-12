require IEx

defmodule Reasoner do
  require Logger

  def reason_cycle(agent) do
    agent_state = ExAgent.agent_state(agent)
    new_agent_state = reason(agent_state)
    ExAgent.set_agent_state(agent, new_agent_state)
  end

  def reason(
             %AgentState{
              events: events,
              beliefs: beliefs,
              plan_rules: plan_rules,
              intents: intents}=agent_state) do
    reason(agent_state, beliefs, plan_rules, events, intents)
  end

  def reason(agent_state, beliefs, plan_rules, events, intents) do

    with {event, rest_events} <- Reasoner.Event.select_event(events),
         {plan, binding} <- Reasoner.Plan.select_plan(plan_rules, beliefs, event),
         {new_intents, new_event} <- Reasoner.Intent.process_intents(intents, event, plan, binding),
         {selected_intent, rest_intents} <- Reasoner.Intent.select_intent(new_intents),
         {new_event, new_intent, new_beliefs} <- Reasoner.Intent.execute_intent(beliefs, selected_intent) do
    Reasoner.AgentState.update_state(agent_state, new_event, rest_events, new_intent, rest_intents, new_beliefs)
   else
     _ -> 1
   end


  end

end
