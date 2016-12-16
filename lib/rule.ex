defmodule Rule do
  defstruct [:event, :context, :body]
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
