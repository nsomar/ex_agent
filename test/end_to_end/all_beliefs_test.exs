defmodule AllBeliefsAgent do
  use ExAgent.Mod
  # use Protocols.only(:asdsa, :aaaa)

  initial_beliefs do
    bel(10)
    bel(20)
    bel(30)
  end

  initialize do
    !perform
  end

  rule (+!perform) do
    all(bel(X), Res)
    +result(Res)
  end

  start()
end

defmodule AllBeliefsAgentTest do
  use ExUnit.Case

  test "it executes the set binding" do
    ag = AllBeliefsAgent.create("ag")
    AllBeliefsAgent.run_loop(ag)
    Process.sleep(300)
    assert AllBeliefsAgent.beliefs(ag) == [bel: {10}, bel: {20}, bel: {30}, result: {[[X: 10], [X: 20], [X: 30]]}]
  end
end