defmodule Executor do

  def execute(%AddBelief{}=add_belief, agent, binding) do
    belief = AddBelief.belief(add_belief, binding)
    bb = EXAgent.belief_base(agent)
    BeliefBase.add_belief(bb, belief)
    binding
  end

  def execute(%RemoveBelief{}=remove_belief, agent, binding) do
    belief = AddBelief.belief(remove_belief, binding)
    bb = EXAgent.belief_base(agent)
    BeliefBase.remove_belief(bb, belief)
    binding
  end

  def execute(%QueryBelief{}=query_belief, agent, binding) do
    belief = QueryBelief.belief(query_belief, binding)
    bb = EXAgent.belief_base(agent)

    BeliefBase.test_belief(bb, belief)
    |> merge_binding(binding)
  end

  def execute(%InternalAction{}=internal_action, agent, binding) do
    InternalActionExecutor.execute(internal_action, agent, binding, ConsolePrinter)
  end

  # def execute(instruction, agent, binding) do
  # end

  defp merge_binding(:cant_unify, _), do: :stop
  defp merge_binding(new, old) do
    new_map = Enum.into(new, %{})
    old_map = Enum.into(old, %{})

    Map.merge(new_map, old_map) |> Map.to_list
  end
end
