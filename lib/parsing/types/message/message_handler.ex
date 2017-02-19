defmodule MessageHandler do
  defstruct [:head, :body, :atomic]
  @type t :: %MessageHandler{head: RuleHead.t, body: RuleBody.t}

  def parse(performative, sender, head, body, atomic \\ false) do
    %MessageHandler {
      head: MessageHandlerHead.parse(performative, sender, head),
      body: RuleBody.parse(body),
      atomic: atomic
    }
  end
end

defimpl PlanHandler, for: MessageHandler do
  def trigger_content(handler) do
    handler.head.trigger.message
  end

  def contexts(handler) do
    handler.head.context.contexts
  end

  def trigger_first_parameter(handler) do
    handler.head.trigger.performative
  end
end
