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

  # test "it prepares the final belief with local calls" do
  #   ast = %AstFunction{ast: {:double, [], [{:__aliases__, [], [:X]}]},
  #  number_of_params: 1, params: [:X]}
  #   bel = %AddBelief{name: :counter, params: [ast]}

  #   assert AddBelief.belief(bel, [X: 12]) == {:counter, {24}}
  # end

end
