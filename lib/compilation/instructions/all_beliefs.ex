defmodule AllBeliefs do

  defstruct [:name, :params, :result]
  @type t :: %AllBeliefs{name: String.t, params: [any], result: String.t}

  def parse({:all, _, [{name, _, params}, {_, _, [result]}]} = statements) when is_tuple(statements) do
    %AllBeliefs{
      name: name,
      params: CommonInstructionParser.parse_params(params),
      result: result,
    }
  end

  def belief(%{name: name, params: params}, binding) do
    {
      name,
      CommonInstructionParser.partial_prepared_params(params, binding)
    }
  end

end
