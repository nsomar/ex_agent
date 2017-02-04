defmodule RuleHead do
  defstruct [:trigger, :context]
  @type t :: %RuleHead{trigger: RuleTrigger.t, context: RuleContext.t}

  def parse(rule) do
    %RuleHead{
      trigger: RuleTrigger.parse(rule),
      context: RuleContext.parse(rule)
    }
  end
end
