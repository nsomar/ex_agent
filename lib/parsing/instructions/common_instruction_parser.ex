defmodule CommonInstructionParser do

  def parse_params(nil), do: []
  def parse_params(params), do: Enum.map(params, &parse_param/1)

  defp parse_param(param) when is_tuple(param), do: AstFunction.create(param)
  defp parse_param(param), do: param

  def prepared_params(params, binding) do
    params
    |> Enum.map(fn item -> prepared_param(item, binding) end)
    |> List.to_tuple
  end

  def prepared_param(%AstFunction{}=param, binding), do: AstFunction.perform(param, binding)
  def prepared_param(param, _), do: param

  def partial_prepared_params(params, binding) do
    params
    |> Enum.map(fn item -> partial_prepared_param(item, binding) end)
    |> List.to_tuple
  end

  def partial_prepared_param(%AstFunction{}=param, binding), do: AstFunction.perform_or_var(param, binding)
  def partial_prepared_param(param, _), do: param

  def get_vars(params), do: Enum.map(params, &get_var/1)

  defp get_var(%AstFunction{}=param), do: param.params
  defp get_var(param), do: param

  def get_single_param({name, _, _}) do
    name
  end

end
