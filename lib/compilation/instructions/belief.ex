defmodule Belief do
  use CommonBeliefParser

  defstruct [:name, :params]
  @type t :: %Belief{name: String.t, params: [any]}

  def parse({name, _, params}) do
    %Belief{
      name: name,
      params: CommonInstructionParser.parse_params(params),
    }
  end

  def parse(_) do
    :not_a_belief
  end

end

defimpl EventContent, for: Belief do
  def content(belief, binding) do
    Belief.belief(belief, binding)
  end
end
