defmodule Executor do

  def execute(%AddBelief{}=add_belief, beliefs, binding) do
    belief = AddBelief.belief(add_belief, binding)
    new_beliefs = BeliefBase.do_add_belief(beliefs, belief)
    {new_beliefs, binding}
  end

  def execute(%RemoveBelief{}=remove_belief, beliefs, binding) do
    belief = AddBelief.belief(remove_belief, binding)
    new_beliefs = BeliefBase.do_remove_belief(beliefs, belief)
    {new_beliefs, binding}
  end

  def execute(%QueryBelief{}=query_belief, beliefs, binding) do
    belief = QueryBelief.belief(query_belief, binding)
    binding =
      beliefs
      |> BeliefBase.do_test_belief(belief)
      |> merge_binding(binding)

    {beliefs, binding}
  end

  def execute(%InternalAction{}=internal_action, beliefs, binding) do
    InternalActionExecutor.execute(internal_action, binding, ConsolePrinter)
    {beliefs, binding}
  end

  def execute(_, beliefs, binding) do
    {beliefs, binding}
  end

  defp merge_binding(:cant_unify, _), do: :stop
  defp merge_binding(new, old) do
    new_map = Enum.into(new, %{})
    old_map = Enum.into(old, %{})

    Map.merge(new_map, old_map) |> Map.to_list
  end
end
