defmodule AstFunction do
  require Logger
  defstruct [:number_of_params, :ast, :params]

  # Creation
  def create(ast) do
    params = parse_vars(ast)
    %AstFunction{
      number_of_params: Enum.count(params),
      params: params,
      ast: flatten_ast(ast)
    }
  end

  # Parsing
  def parse_vars(params) do
    do_parse_vars(params, []) |> List.flatten |> Enum.uniq
  end

  defp do_parse_vars(param, acc) when is_atom(param) do
    if ParsingUtils.var?(param), do: acc ++ param, else: acc
  end

  defp do_parse_vars({_, _, nil}, _) do
    []
  end

  defp do_parse_vars({_, _, params}, acc) do
    params |> Enum.map(fn param ->
      do_parse_vars(param, acc)
    end)
  end

  defp do_parse_vars(_, acc)  do
    acc
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

  # Performing
  def perform(function, params) do
    match = check_all_params_present(function.params, params)
    do_perform(function, params, match)
  end

  defp do_perform(function, params, :ok) do
    prepared_ast =
      function.ast
      |> prepare_ast(function.params, params)

    Logger.info "\nExecuting:\n#{inspect(prepared_ast)}"

    prepared_ast
    |> Code.eval_quoted
    |> elem(0)
  end

  defp do_perform(_, _, _) do
    false
  end

  # Perform Or Return Var
  def perform_or_var(function, params) do
    params = Enum.into(params, %{})

    with {_, var} <- single_var?(function.ast),
          false <- var_in_binding?(var, params) do
        var
    else
      _ -> perform(function, params)
    end
  end

  # defp perform_or_var(function, params, :ok) do
  #   function.ast
  #   |> prepare_ast(function.params, params)
  #   |> Code.eval_quoted
  #   |> elem(0)
  # end

  # defp perform_or_var(_, _, _) do
  #   false
  # end

  defp single_var?({:__aliases__, _, [var]}), do: {true, var}
  defp single_var?(_), do: false

  defp var_in_binding?(var, binding), do: Map.has_key?(binding, var)

  # Prepares the AST
  def prepare_ast(ast, ast_params, params) do
    :ok = check_all_params_present(ast_params, params)
    do_prepare_ast(ast, params)
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

  def check_all_params_present(ast_params, params) do
    unique_params = params |> Enum.map(&elem(&1, 0)) |> Enum.uniq

    if compare_params(ast_params, unique_params) do
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
