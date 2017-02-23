use ExAgent

defagent CounterAgentMac do
  initialize do
    +counter(5)
    !count
  end

  rule (+!count) when counter(0) do
    &print("DONE")
  end

  rule (+!count) when counter(X) do
    &print("Current " <> Integer.to_string(X))
    -+counter(X - 1)
    query(counter(Y))
    &print("New One " <> Integer.to_string(Y))
    !count
  end
end

defmodule CounterAgentMacroTest do
  use ExUnit.Case

  test "agent loop" do
    ag = CounterAgentMac.create("ag")
    ExAgent.Mod.run_loop(ag)
    # IO.inspect "Sss"
    Process.sleep(100)
    assert ExAgent.Mod.agent_state(ag).events == []
    assert ExAgent.Mod.agent_state(ag).intents == []
  end
end
