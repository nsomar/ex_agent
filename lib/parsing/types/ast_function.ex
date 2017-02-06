defmodule AstFunction do
  defstruct [:number_of_params, :ast, :params]

  # Creation
  def create_from_list(asts), do: Enum.map(asts, &create/1)

  def create(ast) do
    params = CommonInstructionParser.parse_vars(ast)
    %AstFunction{
      number_of_params: Enum.count(params),
      params: params,
      ast: flatten_ast(ast)
    }
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
    match = CommonInstructionParser.check_all_params_present(function, params)
    do_perform(function, params, match)
  end

  defp do_perform(function, params, :ok) do
    function.ast
    |> CommonInstructionParser.prepare_ast(function.params, params)
    |> Code.eval_quoted
    |> elem(0)
  end

  defp do_perform(_, _, _) do
    false
  end

end
