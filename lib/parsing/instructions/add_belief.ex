defmodule AddBelief do
  defstruct [:name, :params]
  @type t :: %AddBelief{name: String.t, params: [any]}

  def parse({:+, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %AddBelief{
      name: name,
      params: CommonInstructionParser.parse_params2(params),
    }
  end

  def belief(%AddBelief{name: name, params: params}, binding) do
    {
      name,
      prepared_params(params, binding)
    }
  end
  def prepared_params(params, binding) do
    params
    |> Enum.map(fn item -> prepared_param(item, binding) end)
    |> List.to_tuple
  end

  def prepared_param(%AstFunction{}=param, binding), do: AstFunction.perform(param, binding)
  def prepared_param(param, _), do: param

end
