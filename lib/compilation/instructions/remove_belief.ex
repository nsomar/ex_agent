defmodule RemoveBelief do
  use CommonBeliefParser

  defstruct [:name, :params]
  @type t :: %RemoveBelief{name: String.t, params: [any]}

  def parse({:-, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %RemoveBelief{
      name: name,
      params: CommonInstructionParser.parse_params(params),
    }
  end
end

defimpl EventContent, for: RemoveBelief do
  def content(belief, binding) do
    RemoveBelief.belief(belief, binding)
  end
end
