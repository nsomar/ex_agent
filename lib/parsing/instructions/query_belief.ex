defmodule QueryBelief do

  defstruct [:name, :params]
  @type t :: %QueryBelief{name: String.t, params: [any]}

  def parse({:query, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %QueryBelief{
      name: name,
      params: CommonInstructionParser.parse_params(params),
    }
  end

  def belief(%{name: name, params: params}, binding) do
    {
      name,
      CommonInstructionParser.partial_prepared_params(params, binding)
    }
  end

end
