defmodule MessageHandler do
  defstruct [:head, :body]
  @type t :: %MessageHandler{head: RuleHead.t, body: RuleBody.t}

  def parse(performative, sender, head, body) do
    %MessageHandler {
      head: MessageHandlerHead.parse(performative, sender, head),
      body: RuleBody.parse(body)
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
