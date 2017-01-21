defmodule CommonInstructionParser do
  def parse_params(params) do
    Enum.map(params, &parse_param/1)
  end

  defp parse_param({:__aliases__, _, [param]}), do: param
  defp parse_param(param), do: param
end
