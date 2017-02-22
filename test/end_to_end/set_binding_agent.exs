defmodule SetBindingAgent do
  use ExAgent.Mod
  # use Protocols.only(:asdsa, :aaaa)

  initial_beliefs do
    getZ(10)
    getY(20)
  end

  initialize do
    !count
  end

  rule (+!count) do
    query(getZ(Z))
    query(getY(Y))
    X = Y + Z
    &print(X)
    +result(X)
  end

  start
end

defmodule SetBindingAgentTest do
  use ExUnit.Case

  test "it parses the plans" do
    ag = SetBindingAgent.create("ag")
    rules = ExAgent.plan_rules(ag)
    assert rules |> Enum.count == 1
  end

  test "it executes the set binding" do
    ag = SetBindingAgent.create("ag")
    ExAgent.run_loop(ag)
    Process.sleep(300)
    assert ExAgent.beliefs(ag) == [getZ: {10}, getY: {20}, result: {30}]
  end
end
