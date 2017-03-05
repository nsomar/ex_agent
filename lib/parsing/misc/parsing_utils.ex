defmodule ParsingUtils do

  # Check if an atom is a variable
  def var?(atom) when not is_atom(atom), do: false
  def var?(atom) do
    char = String.at(Atom.to_string(atom), 0)
    equal_case = String.upcase(char) == char
    not_int = :error == Integer.parse(char)
    not_int and equal_case
  end

  # Check if test contains any variable in the binding
  # Takes first: {:money, {:Y}}
  # second: [Y: :"1234"]
  # returns true
  def test_contains_binding({_, test}, binding) do
    Tuple.to_list(test)
    |> Enum.any?(fn item ->
      cond do
        ParsingUtils.var?(item) and binding_contains_var?(binding, item) -> true
        true -> false
      end
    end)
  end

  # Check if binding contains a varialbe
  # Takes first: [Y: :"1234"]
  # second: :Y
  # returns true
  def binding_contains_var?(binding, variable),
    do: binding[variable] != nil

  def number_of_variables({_, test}) do
    Tuple.to_list(test)
    |> Enum.filter(&var?/1)
    |> Enum.uniq
    |> Enum.count
  end

  def func_arity(func) do
    :erlang.fun_info(func)[:arity]
  end

  def get_statements_matching_term(beleifs, term) do
    beleifs |>
    Enum.filter(fn bel -> get_belief_term(bel) == term end) |>
    Enum.map(fn bel -> get_beleif_statement(bel) end)
  end

  def get_belief_term({term, _}), do: term
  def get_belief_term(_), do: :no_term

  def get_beleif_statement({_, statement}), do: statement
  def get_beleif_statement(_), do: :no_term

end
