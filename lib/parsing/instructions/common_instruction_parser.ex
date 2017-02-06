defmodule CommonInstructionParser do
  def parse_params(params) do
    Enum.map(params, &parse_param/1)
  end

  defp parse_param({:__aliases__, _, [param]}), do: param
  defp parse_param(param), do: param

  def parse_params2(nil), do: []
  def parse_params2(params), do: Enum.map(params, &parse_param2/1)


  defp parse_param2(param) when is_tuple(param), do: AstFunction.create(param)
  defp parse_param2(param), do: param


    # Parsing
  def parse_vars(params) do
    do_parse_vars(params, []) |> List.flatten |> Enum.uniq
  end

  defp do_parse_vars(param, acc) when is_atom(param) do
    if ParsingUtils.var?(param), do: acc ++ param, else: acc
  end

  defp do_parse_vars({_, _, nil}, acc) do
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
