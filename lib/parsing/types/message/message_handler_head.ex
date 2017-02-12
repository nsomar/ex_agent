defmodule MessageHandlerHead do
  defstruct [:trigger, :context, :sender]
  @type t :: %MessageHandlerHead{trigger: RuleTrigger.t, context: RuleContext.t, sender: String.t}

  def parse(performative, sender, message_handler) do
    %MessageHandlerHead{
      sender: CommonInstructionParser.get_single_param(sender),
      trigger: MessageHandlerTrigger.parse(performative, message_handler),
      context: RuleContext.parse(message_handler)
    }
  end
end
