defmodule RuleHead do
  defstruct [:trigger, :context]

  def create(rule) do
    %RuleHead{
      trigger: RuleTrigger.parse(rule),
      context: RuleContext.parse(rule)
    }
  end
end
