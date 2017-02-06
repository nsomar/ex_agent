defmodule Executor do

  def execute(%AddBelief{}=add_belief, agent, binding) do
    belief = AddBelief.belief(add_belief, binding)
    bb = EXAgent.belief_base(agent)
    BeliefBase.add_belief(bb, belief)
    binding
  end

  def execute(instruction, agent, binding) do

  end
end
