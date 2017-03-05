defmodule Executor do

  def execute(%AddBelief{}=add_belief, beliefs, binding) do
    belief = AddBelief.belief(add_belief, binding)
    result = BeliefBase.add_belief(beliefs, belief)
    {result, binding}
  end

  def execute(%RemoveBelief{}=remove_belief, beliefs, binding) do
    belief = AddBelief.belief(remove_belief, binding)
    result = BeliefBase.remove_belief(beliefs, belief)
    {result, binding}
  end

  def execute(%ReplaceBelief{}=remove_belief, beliefs, binding) do
    belief = AddBelief.belief(remove_belief, binding)
    result = BeliefBase.replace_belief(beliefs, belief)
    {result, binding}
  end

  def execute(%QueryBelief{}=query_belief, beliefs, binding) do
    belief = QueryBelief.belief(query_belief, binding)
    {result, binding} =
      beliefs
      |> BeliefBase.test_belief(belief)
      |> merge_binding(binding)

    {{result, beliefs}, binding}
  end

  def execute(%InternalAction{}=internal_action, beliefs, binding) do
    {status, _} = InternalActionExecutor.execute(internal_action, binding, ConsolePrinter, ActualMessageSender)
    {{status, beliefs}, binding}
  end

  def execute(%SetBinding{}=set_binding, beliefs, binding) do
    {_, new_bindings} =
      SetBinding.execute(set_binding, binding)
      |> merge_binding(binding)

    {{:binding_changed, beliefs}, new_bindings}
  end


  def execute(_, beliefs, binding) do
    {{:no_change, beliefs}, binding}
  end

  defp merge_binding(:cant_unify, _), do: {:cant_unify, []}
  defp merge_binding(new, old) do
    new_map = Enum.into(new, %{})
    old_map = Enum.into(old, %{})

    {:unified, new_map |> Map.merge(old_map) |> Map.to_list}
  end
end
