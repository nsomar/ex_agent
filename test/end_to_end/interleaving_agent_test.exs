defmodule InterleavingAgent do
  use ExAgent
  # use Protocols.only(:asdsa, :aaaa)

  initialize do
    +execute(1)
    +execute(2)
  end

  rule (+execute(1)) do
    &print("execute 1-1")
    &print("execute 1-2")
    &print("execute 1-3")
    &print("execute 1-4")
    +done1
    !check()
  end

  rule (+execute(2)) do
    &print("execute 2-1")
    &print("execute 2-2")
    &print("execute 2-3")
    &print("execute 2-4")
    +done2
    !check()
  end

  rule (+!check) when done1 && done2 && !printed do
    &print("Done All")
    +printed
  end

  start
end

defmodule InterleavingAgentTest do
  use ExUnit.Case

  test "it parses the plans" do
    ag = InterleavingAgent.create("ag1")
    ExAgent.run_loop(ag)
    Process.sleep(300)
  end
end
