defmodule AgentHelperTests do
  use ExUnit.Case

  test "it parses the beliefs" do
    bels = [
     %Belief{name: :cost, params: [:car, %AstFunction{ast: {{:., [line: 11], [{:__aliases__, [counter: 0, line: 11], [:System]}, :compiled_endianness]}, [], []}, number_of_params: 0, params: []}]},
     %Belief{name: :cost, params: [:iphone, 500]},
     %Belief{name: :color, params: [:car, :red]}
    ]
    assert AgentHelper.prepare_initial_beliefs(bels) ==
    [
      cost: {:car, :little},
      cost: {:iphone, 500},
      color: {:car, :red}
    ]
  end

  test "it catches wrong beliefs" do
    bels = [
     :not_a_belief,
     %Belief{name: :cost, params: [:iphone, 500]},
     %Belief{name: :color, params: [:car, :red]}
    ]
    assert AgentHelper.prepare_initial_beliefs(bels) == {:error,
 "The initial beleifs passed are not correct [:not_a_belief, %Belief{name: :cost, params: [:iphone, 500]}, %Belief{name: :color, params: [:car, :red]}]"}
  end
end
