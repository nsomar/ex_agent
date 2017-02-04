defmodule ContextBelief do
  defstruct [:should_pass, :belief]
  @type t :: %ContextBelief{should_pass: boolean, belief: tuple}

  def create(belief, should_pass) do
    %ContextBelief{
      belief: belief,
      should_pass: should_pass
    }
  end

  def from_belief(belief) do
    %ContextBelief{
      belief: belief,
      should_pass: true
    }
  end

  def from_beliefs(beliefs) do
    beliefs |> Enum.map(&from_belief/1)
  end

end
