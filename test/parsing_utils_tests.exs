defmodule ParsingUtilsTests do
  use ExUnit.Case
  doctest ParsingUtils

  test "it can tel if atom is variable" do
    assert ParsingUtils.var?(:X) == true
    assert ParsingUtils.var?(:x) == false
  end

  test "it can tel if test contains a variable from binding" do
    test = {:color, {:car, :X}}
    binding = [X: 123]
    assert ParsingUtils.test_contains_binding(test, binding) == true
  end

  test "it can tel if test does not contains a variable from binding" do
    test = {:color, {:car, :X}}
    binding = [W: 123]
    assert ParsingUtils.test_contains_binding(test, binding) == false
  end

  test "it counts number of variables in tuple" do
    assert ParsingUtils.number_of_variables({:car, {:color, :X}}) == 1
    assert ParsingUtils.number_of_variables({:car, {:W, :X}}) == 2
    assert ParsingUtils.number_of_variables({:car, {:c, :b}}) == 0
  end

  test "it returns function arity" do
    assert ParsingUtils.func_arity(fn x -> x end) == 1
    assert ParsingUtils.func_arity(fn x, _ -> x end) == 2
    assert ParsingUtils.func_arity(fn -> 1 end) == 0
  end

end
