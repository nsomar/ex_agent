defmodule Executor do

  def execute(%AddBelief{name: name, params: params}=add_belief, agent, binding) do
    # CommonInstructionParser.prepare_ast(add_belief.b, , binding)
    # bb = EXAgent.belief_base(agent)
    # BeliefBase.add_belief(bb, belief)
    binding
  end

  def execute(instruction, agent, binding) do

  end
end
