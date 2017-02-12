defmodule ReplaceBelief do
  use CommonBeliefParser

  defstruct [:name, :params]
  @type t :: %ReplaceBelief{name: String.t, params: [any]}

  def parse({:-, _, [{:+, _, [{name, _, params}]}]} = statements) when is_tuple(statements) do
    %ReplaceBelief{
      name: name,
      params: CommonInstructionParser.parse_params(params),
    }
  end
end

defimpl EventContent, for: ReplaceBelief do
  def content(belief, binding) do
    ReplaceBelief.belief(belief, binding)
  end
end
