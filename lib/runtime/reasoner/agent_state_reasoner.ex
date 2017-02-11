defmodule Reasoner.AgentState do
  require Logger

  def update_state(agent_state, new_event, rest_events, new_intent, rest_intents) do
    %{
      agent_state |
      intents: Reasoner.Intent.build_new_intents(new_intent, rest_intents),
      events: Reasoner.Event.build_new_events(new_event, rest_events)
    }
  end
end
