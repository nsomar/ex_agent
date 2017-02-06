defmodule ContextFunction do
  defstruct [:number_of_params, :ast, :params]

  # Checking
  def is_test({:test, _}), do: true
  def is_test(_), do: false

  # Creation
  def create({test}) do
    params = CommonInstructionParser.parse_vars(test)
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

  # Substitution
  def prepare_ast(function, params) do
    :ok = check_all_params_present(function, params)
    do_prepare_ast(function.ast, params)
  end

  def do_prepare_ast({:__aliases__, _, [param]}, params_values) when is_atom(param) do
   params_values[param]
  end

  def do_prepare_ast({op, _, params}, params_values) when is_list(params) do
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
    match = check_all_params_present(function, params)
    do_perform(function, params, match)
  end

  defp do_perform(function, params, :ok) do
    function
    |> prepare_ast(params)
    |> Code.eval_quoted
    |> elem(0)
  end

  defp do_perform(_, _, _) do
    false
  end

  # Check params
  def check_all_params_present(function, params) do
    fp = function.params
    unique_params = params |> Enum.map(&elem(&1, 0)) |> Enum.uniq

    if compare_params(fp, unique_params) do
      :ok
    else
      {:error, "wrong params passed"}
    end
  end

  defp compare_params(p1, p2) do
    sp1 = Enum.into(p1, %MapSet{})
    sp2 = Enum.into(p2, %MapSet{})

    MapSet.subset?(sp1, sp2)
  end
end
