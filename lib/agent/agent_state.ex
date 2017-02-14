defmodule AgentState do
  defstruct [
    :beliefs, :plan_rules, :recovery_handlers, :message_handlers,
    :intents, :events, :name, :module, :messages
  ]
end
