defmodule Rule do
  defstruct [:head, :body]

  def parse(head, body) do
    # body |> IO.inspect
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
