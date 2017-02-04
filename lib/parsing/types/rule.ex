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

defmodule PlanRules do
  use GenServer

  def handle_call({:add_rule, rule}, _from, state) do
    new = state ++ [rule]
    {:reply, new, new}
  end

  def create do
    GenServer.start(__MODULE__, [])
  end

end
