use ExAgent

defresp PingTestMacroResponsibility do
  message(:inform, Sender, ping) do
    &print("PING")
    &send(Sender, :inform, pong)
  end
end

defresp PongTestMacroResponsibility do
  message(:inform, Sender, pong) do
    &print("PONG")
    &send(Sender, :inform, ping)
  end
end

defagent PingTestRespMacroAgent do
  responsibilities do
    PingTestMacroResponsibility
  end
end

defagent PongTestRespMacroAgent do
  responsibilities do
    PongTestMacroResponsibility
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

    ExAgent.run_loop(ping)
    ExAgent.run_loop(pong)

    Process.sleep(200)
    Process.exit(ping, 0)
    Process.exit(pong, 0)
  end
end
