use ExAgent

defrole PingTestMacroRole do
  message(:inform, Sender, ping) do
    &print("PING")
    &send(Sender, :inform, pong)
  end
end

defrole PongTestMacroRole do
  message(:inform, Sender, pong) do
    &print("PONG")
    &send(Sender, :inform, ping)
  end
end

defagent PingTestRespMacroAgent do
  roles do
    PingTestMacroRole
  end
end

defagent PongTestRespMacroAgent do
  roles do
    PongTestMacroRole
  end

  initialize do
    &send(PingTestRespMacroAgent.agent_name("ag1"), :inform, ping)
  end
end

defmodule PingPongTestUseMacroAgentTest do
  use ExUnit.Case

  test "it handle messages" do
    ping = PingTestRespMacroAgent.create("ag1")
    pong = PongTestRespMacroAgent.create("ag2")

    ExAgent.Mod.run_loop(ping)
    ExAgent.Mod.run_loop(pong)

    Process.sleep(200)
    Process.exit(ping, 0)
    Process.exit(pong, 0)
  end
end
