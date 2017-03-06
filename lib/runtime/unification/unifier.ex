defmodule Unifier do
  @moduledoc """
  Unifier module.
  """


  @doc """
  Unifies a list of beliefs with a list of tests
  Returns the found bindings or :cant_unify

  ## Examples

      iex>Unifier.unify_list([{:car, {:color, :red}}], [ContextBelief.create({:car, {:color, :red}}, true)])
      [[]]

      iex>Unifier.unify_list([{:car, {:color, :red}}], [ContextBelief.create({:car, {:speed, :fast}}, true)])
      :cant_unify

      iex>Unifier.unify_list([{:car, {:color, :red}}], [ContextBelief.create({:car, {:X, :Y}}, true)])
      [[X: :color, Y: :red]]
  """
  def unify_list(beleifs, tests, func) do
    beleifs |> do_unify_list(tests, [[]]) |> prepare_list_for_return(func)
  end

  @doc """
  Same as the above method, but without func
  """
  def unify_list(beleifs, tests) do
    beleifs |> do_unify_list(tests, [[]]) |> prepare_list_for_return(nil)
  end

  @doc """
  Same as the above method, but starts with non empty binding
  """
  def unify_list_with_binding(beleifs, tests, func, prior_bindings) do
    beleifs |> do_unify_list(tests, prior_bindings) |> prepare_list_for_return(func)
  end

  @doc """
  Same as the above method, but starts with non empty binding
  """
  def unify_list_with_binding(beleifs, tests, prior_bindings) do
    beleifs |> do_unify_list(tests, prior_bindings) |> prepare_list_for_return(nil)
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
  defp prepare_list_for_return(:cant_unify, _), do: :cant_unify
  defp prepare_list_for_return(list, nil), do: list
  defp prepare_list_for_return(list, func) do
    func_arg_count = ParsingUtils.func_arity(func)

    res = Enum.filter(list, fn item ->
      params = item |> Enum.map(fn {_, bound} -> bound end)
      apply_params_to_func(func, func_arg_count, params)
    end)
    case res do
      [] -> :cant_unify
      res -> res
    end
  end

  @doc """
  Unifes a list of beleifs with a single test

  ## Example
      iex>Unifier.unify([{:car, {:color, :red}}], ContextBelief.create({:car, {:color, :red}}, true))
      [[]]

      iex>Unifier.unify([{:car, {:color, :red}}], ContextBelief.create({:car, {:color, :red1}}, true))
      [:cant_unify]
  """
  def unify(list, %ContextBelief{belief: {term, statement}})
   when is_list(list) do
      list
      |> ParsingUtils.get_statements_matching_term(term)
      |> Enum.map(fn bel -> unify_tuples(bel, statement) end)
  end

  @doc """
  Unifies two beleifs and returns the binding

     iex>Unifier.unify_tuples({:car, {:color, :red}, {:car, {:color, X})
     []
  """
  def unify_tuples({left_term, left_statement}, {right_term, right_statement})
  when is_tuple(left_statement) and is_tuple(right_statement) and left_term == right_term do
   unify_tuples(left_statement, right_statement)
  end

   @doc """
   Unifies belief statements

      iex>Unifier.unify_tuples({:color, :red}, {:color, :red})
      []
   """
   def unify_tuples(left, right)
   when is_tuple(left) and is_tuple(right) do
    unify_with_binding(Tuple.to_list(left), Tuple.to_list(right), [])
   end

   def unify_tuples(_, _), do: :cant_unify


   # Unify with binding
   defp unify_with_binding(left, right, _)
   when is_list(left) and is_list(right) and
        length(left) != length(right) do
     :cant_unify
   end

   defp unify_with_binding([hl| tl], [hr| tr], binding) do
     cond do
       hr == hl ->
         unify_with_binding(tl, tr, binding)
       ParsingUtils.var?(hr) ->
         unify_with_binding(tl, tr, binding ++ [{hr, hl}])
       true ->
         :cant_unify
     end
   end

  defp unify_with_binding([], [], binding) do
    binding
  end

  # Unify a list of beliefs with a test and prior binding
  def unify_beleifs_with_test_and_bindings(beleifs, test, [[]]) do
    beleifs
    |> unify(test)
    |> remove_ununified
    |> adjust_result_for_unification(test)
  end

  def unify_beleifs_with_test_and_bindings(beleifs, %{belief: belief, should_pass: should_pass}, bindings) do
    [h| _] = bindings

    if ParsingUtils.test_contains_binding(belief, h) do
      belief
      |> multiple_bind_variables(bindings)
      |> Enum.map(fn {binding, bound_test} ->
        new_test = ContextBelief.create(bound_test, should_pass)

        res =
        beleifs
        |> unify(new_test)
        |> remove_ununified
        |> adjust_result_for_unification(new_test)

        # {new_test, res, adjusted} |> IO.inspect
        {binding, res}
      end)
      |> Enum.map(
        fn
          {_, :cant_unify} ->
            :cant_unify
          {binding, result} ->
            result |> Enum.map(fn x -> binding ++ x end) |> List.flatten
      end)
    else
      beleifs
      |> unify_beleifs_with_test_and_bindings(ContextBelief.create(belief, should_pass), [[]])
      |> add_binding_to_bindings(bindings)
    end
    |> remove_ununified
  end

  defp adjust_result_for_unification(unification, %{should_pass: should_pass})
    when should_pass == true,
    do: unification

  defp adjust_result_for_unification(:cant_unify, %{should_pass: should_pass})
    when should_pass == false,
    do: [[]]

  defp adjust_result_for_unification(_, %{should_pass: should_pass})
    when should_pass == false,
    do: :cant_unify

  @doc """
  Add a new binding to the list of prior bindings
  new_bindings: list of new bindings
  bindings: list of old bindings

  ## Example:
      iex> Unifier.add_binding_to_bindings([[X: :"1000"]], [[]])
      [[X: :"1000"]]
  """
  def add_binding_to_bindings(:cant_unify, _), do: []
  def add_binding_to_bindings(new_bindings, bindings) do

    bindings
    |> Enum.map(fn binding ->
      # IO.inspect "Mergings"
      # IO.inspect "binding #{inspect(binding)}"
      # IO.inspect "new binding #{inspect(new_bindings)}"
      new_bindings
      |> Enum.map(fn new_binding ->
        binding ++ new_binding
      end)
      |> List.flatten
    end)
  end

  def remove_ununified(:cant_unify), do: []
  def remove_ununified(unification_result) when is_list(unification_result),
    do: unification_result |> Enum.filter(&(&1 != :cant_unify)) |> check_for_unification

  def check_for_unification([]), do: :cant_unify
  def check_for_unification(unification_result), do: unification_result

  # Binds multiple variables in a test
  # Takes first: {:money, {:Y, :X}}
  # second: [Y: :"1234", X: "123"]
  # returns {[Y: :"1234", X: "123"], {:money, {:"1234", "123"}}}
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
       ParsingUtils.var?(x) and ParsingUtils.binding_contains_var?(binding, x) -> binding[x]
       true -> x
     end
   end)
    |> List.to_tuple

    {term, res}
  end

  # Apply a set of params to a func if the airty match
  defp apply_params_to_func(func, airty, params) when length(params) == airty,
    do: apply(func, params)
  defp apply_params_to_func(_, _, _),
    do: false

 end
