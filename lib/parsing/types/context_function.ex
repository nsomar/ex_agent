defmodule ContextFunction do

  # Creation
  def create({test}) do
    %{
      number_of_params: number_of_params,
      params: params,
      ast: ast
    } = AstFunction.create(test)
    %AstFunction{
      number_of_params: number_of_params,
      params: params,
      ast: flatten_ast(ast)
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

end
