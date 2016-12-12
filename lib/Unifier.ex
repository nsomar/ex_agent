defmodule Unifier do
  @moduledoc """
  Unifier module.
  """


  @doc """
  Unifies a list of beliefs with a list of tests
  Returns the found bindings or :cant_unify

  ## Examples

      iex>Unifier.unify_list([{:car, {:color, :red}}], [{:car, {:color, :red}}])
      [[]]

      iex>Unifier.unify_list([{:car, {:color, :red}}], [{:car, {:speed, :fast}}])
      :cant_unify

      iex>Unifier.unify_list([{:car, {:color, :red}}], [{:car, {:X, :Y}}])
      [[X: :color, Y: :red]]
  """
  def unify_list(beleifs, tests, func) do
    do_unify_list(beleifs, tests, [[]]) |> prepare_list_for_return(func)
  end

  def unify_list(beleifs, tests) do
    do_unify_list(beleifs, tests, [[]]) |> prepare_list_for_return(nil)
  end

  defp do_unify_list(_, _, :cant_unify), do: :cant_unify
  defp do_unify_list(_, [], bindings), do: bindings
  defp do_unify_list(beleifs, [h| t], bindings) do
    # IO.inspect "-------"
    # IO.inspect "original bind #{inspect(bindings)}"

    res = unify_beleifs_with_test_and_bindings(beleifs, h, bindings)
    # IO.inspect "new binding #{inspect(res)}"

    # bindings = add_binding_to_bindings(res, bindings)
    # IO.inspect "merged binding #{inspect(bindings)}"
    # IO.inspect "-------"
    do_unify_list(beleifs, t, res)
  end

  # Filter a list of binding by passing them through a filter
  defp prepare_list_for_return(list, nil), do: list
  defp prepare_list_for_return(list, func) do
    case Enum.filter(list, func) do
      [] -> :cant_unify
      res -> res
    end
  end

  @doc """
  Unifes a list of beleifs with a single test

  ## Example
      iex>Unifier.unify([{:car, {:color, :red}}], {:car, {:color, :red}})
      [[]]

      iex>Unifier.unify([{:car, {:color, :red}}], {:car, {:color, :red1}})
      [:cant_unify]
  """
  def unify(list, {term, statement})
   when is_list(list) do

    BeliefUtil.get_statements_matching_term(list, term)
    |> Enum.map(fn bel ->
      unify(bel, statement)
    end)
   end

   def unify(left, right)
   when is_tuple(left) and is_tuple(right) do
    unify(Tuple.to_list(left), Tuple.to_list(right), [])
   end

   def unify(_, _), do: :cant_unify

   def unify(left, right, _)
   when is_list(left) and is_list(right) and
        length(left) != length(right) do
     :cant_unify
   end

   def unify([hl| tl], [hr| tr], binding)do
     cond do
       hr == hl ->
         unify(tl, tr, binding)
       var?(hr) ->
         unify(tl, tr, binding ++ [{hr, hl}])
       true ->
         :cant_unify
     end
   end

  def unify([], [], binding) do
    binding
  end

  # Unify a list of beliefs with a test and prior binding
  def unify_beleifs_with_test_and_bindings(beleifs, test, [[]]) do
    unify(beleifs, test) |> remove_ununified
  end

  def unify_beleifs_with_test_and_bindings(beleifs, test, bindings) do
    [h| _] = bindings

    if test_contains_binding(test, h) do
      multiple_bind_variables(test, bindings)
      |> Enum.map(fn {binding, bound_test} ->
        # IO.inspect bound_test
        res = unify(beleifs, bound_test) |> remove_ununified
        {binding, res}
      end)
      |> Enum.filter(fn {_, result} ->
        # IO.inspect "Trying to remove #{inspect(result)}"
        result != :cant_unify
      end)
      |> Enum.map(fn {binding, result} ->
        # IO.inspect "Trying to merge #{inspect(result)} into #{inspect(binding)}"
        Enum.map(result, fn x -> binding ++ x end) |> List.flatten
      end)
    else

      unify_beleifs_with_test_and_bindings(beleifs, test, [[]])
      |> add_binding_to_bindings(bindings)
    end
    |> remove_ununified
  end


  @doc """
  Add a new binding to the list of prior bindings
  new_bindings: list of new bindings
  bindings: list of old bindings

  ## Example:
      iex> Unifier.add_binding_to_bindings([[X: :"1000"]], [[]])
      [[X: :"1000"]]
  """
  def add_binding_to_bindings(new_bindings, bindings) do
    Enum.map(bindings, fn binding ->
      # IO.inspect "Mergings"
      # IO.inspect "binding #{inspect(binding)}"
      # IO.inspect "new binding #{inspect(new_bindings)}"
      Enum.map(new_bindings, fn new_binding ->
        binding ++ new_binding
      end)
      |> List.flatten
    end)
  end
  # def add_binding_to_bindings(:cant_unify, _), do: :cant_unify
  # def add_binding_to_bindings([[]], bindings), do: bindings
  # def add_binding_to_bindings(new_binding, [[]]), do: new_binding
  # def add_binding_to_bindings(l, r) when l == r, do: l

  def remove_ununified(unification_result) when is_list(unification_result),
    do: unification_result |> Enum.filter(&( &1 != :cant_unify )) |> check_for_unification

  def check_for_unification([]), do: :cant_unify
  def check_for_unification(unification_result), do: unification_result

  # Binds multiple variables in a test
  # Takes first: {:money, {:Y, :X}}
  # second: [Y: :"1234", X: "123"]
  # returns {:money, {:"1234", "123"}}
  def multiple_bind_variables(test, [[]]), do: [test]
  def multiple_bind_variables(test, bindings) do
    bindings |> Enum.map(fn binding ->
      {binding, bind_variables(test, binding)}
    end)
  end

  # Bind a variable in a term
  # Takes first: {:money, {:Y}}
  # second: [Y: :"1234"]
  # returns {:money, {:"123"}}
  def bind_variables({term, statement}, binding) do
    res =
    Tuple.to_list(statement)
    |> Enum.map(fn x ->
     cond do
       var?(x) and binding_contains_var(binding, x) -> binding[x]
       true -> x
     end
   end)
    |> List.to_tuple

    {term, res}
  end

  # Check if test contains any variable in the binding
  # Takes first: {:money, {:Y}}
  # second: [Y: :"1234"]
  # returns true
  def test_contains_binding({_, test}, binding) do
    Tuple.to_list(test)
    |> Enum.any?(fn item ->
      cond do
        var?(item) and binding_contains_var(binding, item) -> true
        true -> false
      end
    end)
  end

  # Check if an atom is a variable
  defp var?(atom) when not is_atom(atom), do: false
  defp var?(atom) do
    char = String.at(Atom.to_string(atom), 0)
    equal_case = String.upcase(char) == char
    not_int = :error == Integer.parse(char)
    not_int and equal_case
  end

  # Check if binding contains a varialbe
  # Takes first: [Y: :"1234"]
  # second: :Y
  # returns true
  defp binding_contains_var(binding, variable),
    do: binding[variable] != nil

 end
