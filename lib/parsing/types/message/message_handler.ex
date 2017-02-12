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
