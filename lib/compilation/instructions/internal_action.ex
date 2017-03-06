defmodule InternalAction do
  defstruct [:name, :params]
  @type t :: %InternalAction{name: String.t, params: [any]}

  def parse({:&, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %InternalAction{
      name: name,
      params: CommonInstructionParser.parse_params(params),
    }
  end

  def params(%InternalAction{params: params}, binding) do
    CommonInstructionParser.prepared_params(params, binding) |> Tuple.to_list
  end

end
