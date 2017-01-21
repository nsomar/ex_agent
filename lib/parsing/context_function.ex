defmodule ContextFunction do
  defstruct [:number_of_params, :ast, :params]

  # Checking
  def is_test({:test, _}), do: true
  def is_test(_), do: false

  # Creation
  def create({test}) do
    params = get_params(test)
    %ContextFunction{
      number_of_params: Enum.count(params),
      params: params,
      ast: flatten_ast(test)
    }
  end

  # Flatten AST
  defp flatten_ast({:test, _, [ast]}) do
    flatten_ast(ast)
  end

  defp flatten_ast({op, _, params}) do
    flat_params = params |> Enum.map(fn param ->
      flatten_ast(param)
    end)
    {op, [], flat_params}
  end

  defp flatten_ast(any) do
    any
  end

  # Parsing
  def get_params(test) do
    do_get_params(test, []) |> List.flatten |> Enum.uniq
  end

  defp do_get_params(param, acc) when is_atom(param) do
    acc ++ param
  end

  defp do_get_params({ _, _, params}, acc) do
    params |> Enum.map(fn param ->
      do_get_params(param, acc)
    end)
  end

  defp do_get_params(_, acc)  do
    acc
  end

  # Substitution
  def prepare_ast(function, params) do
    :ok = check_all_params_present(function, params)
    do_prepare_ast(function.ast, params)
  end

  def do_prepare_ast({:__aliases__, _, [param]}, params_values) when is_atom(param) do
   params_values[param]
  end

  def do_prepare_ast({op, _, params}, params_values) when is_list(params) do
    abcdef = {op, [], []}
    prepared_params =
    params |> Enum.map(fn param ->
      do_prepare_ast(param, params_values)
    end)
    {op, [], prepared_params}
  end

  def do_prepare_ast(any, _) do
    any
  end

  # Performing
  def perform(function, params) do
    ast = prepare_ast(function, params)
    Code.eval_quoted(ast) |> elem(0)
  end

  # Check params
  def check_all_params_present(function, params) do
    fp = function.params
    unique_params = params |> Enum.map(&elem(&1, 0)) |> Enum.uniq

    with true <- Enum.count(fp) == Enum.count(unique_params),
      true <- compare_params(fp, unique_params) do
        :ok
    else
      _ -> {:error, "wrong params passed"}
    end
  end

  defp compare_params(p1, p2) do
    sp1 = Enum.sort(p1)
    sp2 = Enum.sort(p2)

    compared = Enum.zip(sp1, sp2) |> Enum.filter(fn item ->
      elem(item, 0) == elem(item, 1)
    end)

    Enum.count(compared) == Enum.count(sp1)
  end
end













