 defmodule Unifier do

  def unify_list(beleifs, tests) do
    unify_list(beleifs, tests, [[]])
  end

  def unify_list(_, _, :cant_unify), do: :cant_unify

  def unify_list(_, [], bindings), do: bindings

  def unify_list(beleifs, [h| t], bindings) do
    # IO.inspect "-------"
    # IO.inspect "original bind #{inspect(bindings)}"

    res = unify_beleifs_with_test_and_bindings(beleifs, h, bindings)
    # IO.inspect "new binding #{inspect(res)}"

    # bindings = add_binding_to_bindings(res, bindings)
    # IO.inspect "merged binding #{inspect(bindings)}"
    # IO.inspect "-------"
    unify_list(beleifs, t, res)

  end

  def unify_beleifs_with_test_and_bindings(beleifs, test, [[]]) do
    unify(beleifs, test) |> remove_ununified
  end

  def unify_beleifs_with_test_and_bindings(beleifs, test, bindings) do
    [h| _] = bindings

    if test_contains_binding(test, h) do

      multiple_bind_variables(test, bindings)
      |> Enum.map(fn {binding, bound_test} ->
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

  def add_binding_to_bindings(:cant_unify, _), do: :cant_unify
  def add_binding_to_bindings([[]], bindings), do: bindings
  def add_binding_to_bindings(new_binding, [[]]), do: new_binding
  def add_binding_to_bindings([], bindings), do: bindings
  def add_binding_to_bindings(l, r) when l == r, do: l

  # def add_binding_to_bindings(new_bindings, bindings) do
  # end

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

  def merge_bindings(new_binding, binding) do
    new_binding ++ binding
  end

   def unify(list, right)
   when is_list(list) and is_tuple(right) do
     Enum.map(list, fn bel ->
       unify(bel, right)
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
       is_var(hr) ->
         unify(tl, tr, binding ++ [{hr, hl}])
       true ->
         :cant_unify
     end
   end

   def unify([], [], binding) do
     binding
   end

   def remove_ununified(unification_result) when is_list(unification_result) do
     unification_result |> Enum.filter(&( &1 != :cant_unify )) |> check_for_unification
   end

   def check_for_unification([]), do: :cant_unify
   def check_for_unification(unification_result), do: unification_result

   defp is_var(atom) do
     char = String.at(Atom.to_string(atom), 0)
     equal_case = String.upcase(char) == char
     not_int = :error == Integer.parse(char)
     not_int and equal_case
   end

   def multiple_bind_variables(test, [[]]), do: [test]

   def multiple_bind_variables(test, bindings) do
     bindings |> Enum.map(fn binding ->
       {binding, bind_variables(test, binding)}
    end)
   end

   def test_contains_binding(test, binding) do
     Tuple.to_list(test)
     |> Enum.any?(fn item ->
       cond do
         is_var(item) and binding_contains_var(binding, item) -> true
         true -> false
       end
     end)
   end

   def bind_variables(test, binding) do
     Tuple.to_list(test)
     |> Enum.map(fn x ->
       cond do
         is_var(x) and binding_contains_var(binding, x) -> binding[x]
         true -> x
       end
     end)
     |> List.to_tuple
   end

   defp binding_contains_var(binding, variable) do
     binding[variable] != nil
   end
 end
