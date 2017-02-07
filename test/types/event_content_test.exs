defmodule EventContentTest do
  use ExUnit.Case

  test "gets content of a add belief" do
    ast = %AstFunction{ast: {:+, [], [{:__aliases__, [], [:X]}, 10]}, number_of_params: 1, params: [:X]}
    bel = %AddBelief{name: :counter, params: [ast]}

    assert EventContent.content(bel, [X: 12]) == {:counter, {22}}
  end

  test "gets content of a remove belief" do
    ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
    bel = %RemoveBelief{name: :counter, params: [ast]}

    assert EventContent.content(bel, [X: 12]) == {:counter, {12}}
  end

  test "gets content of a goal" do
    ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
    goal = %AchieveGoal{name: :counter, params: [ast]}

    assert EventContent.content(goal, [X: 123]) == {:counter, {123}}
  end

end
