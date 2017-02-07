defmodule InstructionParamsTestDoubler do
  def double(val), do: val * 2
end

defmodule InstructionParamsTest do
  use ExUnit.Case

  test "it prepares the final belief with simple params" do
    bel = %AddBelief{name: :man, params: [:omar]}

    assert AddBelief.belief(bel, []) == {:man, {:omar}}
  end

  test "it prepares the final belief with simple ast" do
    ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
    bel = %AddBelief{name: :has_car, params: [ast]}

    assert AddBelief.belief(bel, [X: 1]) == {:has_car, {1}}
  end

  test "it prepares the final belief with arithmatic" do
    ast = %AstFunction{ast: {:+, [], [{:__aliases__, [], [:X]}, 10]}, number_of_params: 1, params: [:X]}
    bel = %AddBelief{name: :counter, params: [ast]}

    assert AddBelief.belief(bel, [X: 1]) == {:counter, {11}}
  end

  test "it prepares the final belief with arithmatic and 2 vars" do
    ast = %AstFunction{ast: {:+, [], [{:__aliases__, [], [:X]}, {:__aliases__, [], [:Y]}]}, number_of_params: 1, params: [:X]}
    bel = %AddBelief{name: :counter, params: [ast]}

    assert AddBelief.belief(bel, [X: 1, Y: 7]) == {:counter, {8}}
  end

  test "it prepares the final belief with external calls" do
    ast = %AstFunction{ast: {{:., [line: 6],
     [{:__aliases__, [counter: 0, line: 6], [:InstructionParamsTestDoubler]}, :double]}, [],
    [{:__aliases__, [], [:X]}]}, number_of_params: 1, params: [:X]}
    bel = %AddBelief{name: :counter, params: [ast]}

    assert AddBelief.belief(bel, [X: 12]) == {:counter, {24}}
  end

  test "it parses remove belief" do
    ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
    bel = %RemoveBelief{name: :counter, params: [ast]}

    assert RemoveBelief.belief(bel, [X: 12]) == {:counter, {12}}
  end

  test "it parses achieve goal" do
    ast = %AstFunction{ast: {:+, [],
       [{:__aliases__, [], [:X]}, {:__aliases__, [], [:Y]}]},
      number_of_params: 2, params: [:X, :Y]}
    bel = %AchieveGoal{name: :counter, params: [ast]}

    assert AchieveGoal.goal(bel, [X: 12, Y: 1]) == {:counter, {13}}
  end

  test "it parses query belief" do
    ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
    bel = %AchieveGoal{name: :counter, params: [ast]}

    assert QueryBelief.belief(bel, []) == {:counter, {:X}}
  end

  test "it parses query belief 2" do
    bel = %QueryBelief{name: :counter, params: [1, 2]}

    assert QueryBelief.belief(bel, []) == {:counter, {1, 2}}
  end

  test "it parses internal action" do
    inst = %InternalAction{name: :print, params: [1, 2, 3]}

    assert InternalAction.params(inst, []) == [1, 2, 3]
  end

  # test "it parses internal action 1" do
  #   inst = %InternalAction{name: :print, params: [%AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1,
  #     params: [:Y]}, 2, 3]}

  #   assert InternalAction.get_params(inst, []) == [1, 2, 3]
  # end

  test "it parses internal action 2" do
    inst = %InternalAction{name: :print,
    params: [%AstFunction{ast: {:+, [], [{:__aliases__, [], [:X]}, 1]},
      number_of_params: 1, params: [:X]},
     %AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1,
      params: [:Y]},
     %AstFunction{ast: {:*, [], [{:__aliases__, [], [:Z]}, 2]},
      number_of_params: 1, params: [:Z]}]}

    assert InternalAction.params(inst, [X: 10, Y: 20, Z: 30]) == [11, 20, 60]
  end

  test "it parses query beliefs with params" do
    # %AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1, params: [:Y]}, 2, 3
    inst = %QueryBelief{name: :print, params: [1, 2]}
    assert QueryBelief.belief(inst, []) == {:print, {1, 2}}
  end

  test "it parses query beliefs with unbounded vars" do
    ast = %AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1, params: [:Y]}
    inst = %QueryBelief{name: :print, params: [1, ast]}
    assert QueryBelief.belief(inst, []) == {:print, {1, :Y}}
  end

  test "it parses query beliefs with bounded vars" do
    ast = %AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1, params: [:Y]}
    inst = %QueryBelief{name: :print, params: [1, ast]}
    assert QueryBelief.belief(inst, [Y: 10]) == {:print, {1, 10}}
  end

  # test "it prepares the final belief with local calls" do
  #   ast = %AstFunction{ast: {:double, [], [{:__aliases__, [], [:X]}]},
  #  number_of_params: 1, params: [:X]}
  #   bel = %AddBelief{name: :counter, params: [ast]}

  #   assert AddBelief.belief(bel, [X: 12]) == {:counter, {24}}
  # end

end
