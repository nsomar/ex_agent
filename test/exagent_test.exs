defmodule ExagentTest do
  use ExUnit.Case
  doctest EXAgent

  test "can add beleif" do
    EXAgent.start()
    val = EXAgent.add_belief({:color, :red})
    assert val == :added
  end

  test "cen get beliefs" do
    EXAgent.start()
    :added = EXAgent.add_belief({:color, :red})
    :added = EXAgent.add_belief({:color, :yellow})
    :added = EXAgent.add_belief({:age, 123})
    :added = EXAgent.add_belief({:tempreture, :red, 123})

    bels = EXAgent.get_beliefs
    assert length(bels) == 4
  end

  test "can remove a beleif" do
    EXAgent.start()
    :added = EXAgent.add_belief({:color, :red})
    :added = EXAgent.add_belief({:color, :yellow})

    bels = EXAgent.get_beliefs
    assert length(bels) == 2

    :removed = EXAgent.remove_belief({:color, :yellow})
    
  end
end
