defmodule RuleHead do
  defstruct [:trigger, :context]

  def parse(rule) do
    %RuleHead{
      trigger: RuleTrigger.parse(rule),
      context: RuleContext.parse(rule)
    }
  end
end
