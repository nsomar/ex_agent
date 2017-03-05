defmodule BeliefBase do
  def add_belief(beliefs, belief) when is_list(beliefs) and is_tuple(belief) do
    case has_belief(beliefs, belief) do
      true -> {:already_added, beliefs}
      false -> {:added, beliefs ++ [belief]}
    end
  end

  def remove_belief(beliefs, belief) when is_list(beliefs) and is_tuple(belief) do
    case has_belief(beliefs, belief) do
      true -> {:removed, Enum.filter(beliefs, fn b -> b != belief end)}
      false -> {:not_found, beliefs}
    end
  end

  def replace_belief(beliefs, {name, params}=belief) when is_list(beliefs) do
    found_beliefs =
      beliefs
      |> Enum.filter(
        fn {c_name, c_params} ->
          name == c_name && tuple_size(params) == tuple_size(c_params)
      end)

    new_beliefs = Enum.reduce(found_beliefs, beliefs, fn (bel, beliefs) ->
      {:removed, new_beliefs} = remove_belief(beliefs, bel)
      new_beliefs
    end)

    {:added, new_beliefs} = add_belief(new_beliefs, belief)
    {[removed: found_beliefs, added: belief], new_beliefs}
  end

  def test_belief(beliefs, test) when is_list(beliefs) and is_tuple(test),
    do: Unifier.unify(beliefs, test |> ContextBelief.from_belief) |> prepare_return

  def test_beliefs(beliefs, %Context{tests: tests}) when is_list(beliefs) and is_list(tests),
    do: Unifier.unify_list(beliefs, tests |> ContextBelief.from_beliefs, nil) |> prepare_return

  def test_beliefs(beliefs, tests) when is_list(beliefs) and is_list(tests),
    do: Unifier.unify_list(beliefs, tests |> ContextBelief.from_beliefs, nil) |> prepare_return

  def test_beliefs(beliefs, tests, %Context{tests: tests, function: fun}) when is_list(beliefs) and is_list(tests) do
    Unifier.unify_list(beliefs, tests |> ContextBelief.from_beliefs, fun) |> prepare_return
  end

  def test_beliefs(beliefs, tests, fun) when is_list(beliefs) and is_list(tests) do
    Unifier.unify_list(beliefs, tests |> ContextBelief.from_beliefs, fun) |> prepare_return
  end

  defp has_belief(beliefs, belief) do
    Enum.any?(beliefs, fn bel -> bel == belief end)
  end

  defp prepare_return([h| _]), do: h
  defp prepare_return(_), do: :cant_unify
end
