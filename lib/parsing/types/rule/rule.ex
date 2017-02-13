defmodule Rule do
  defstruct [:head, :body]
  @type t :: %Rule{head: RuleHead.t, body: RuleBody.t}

  def parse(head, body) do
    %Rule {
      head: RuleHead.parse(head),
      body: RuleBody.parse(body)
    }
  end
end

defimpl PlanHandler, for: Rule do
  def trigger_content(rule) do
    rule.head.trigger.content
  end

  def contexts(rule) do
    rule.head.context.contexts
  end

  def trigger_first_parameter(rule) do
    rule.head.trigger.event_type
  end
end
