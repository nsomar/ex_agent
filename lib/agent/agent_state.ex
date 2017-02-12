defmodule AgentState do
  defstruct [:beliefs, :plan_rules, :message_handlers, :intents, :events, :name, :module, :messages]
end
