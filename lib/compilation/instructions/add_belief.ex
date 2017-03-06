defmodule AddBelief do
  use CommonBeliefParser

  defstruct [:name, :params]
  @type t :: %AddBelief{name: String.t, params: [any]}

  def parse({:+, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %AddBelief{
      name: name,
      params: CommonInstructionParser.parse_params(params),
    }
  end
end

defimpl EventContent, for: AddBelief do
  def content(belief, binding) do
    AddBelief.belief(belief, binding)
  end
end
