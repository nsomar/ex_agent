defmodule PingTestResponsibility do
  use ExAgent.Core

  message(:inform, Sender, ping) do
    &print("PING")
    &send(Sender, :inform, pong)
  end

  start
end

defmodule PongTestResponsibility do
  use ExAgent.Core

  message(:inform, Sender, pong) do
    &print("PONG")
    &send(Sender, :inform, ping)
  end

  start
end

defmodule PingTestRespAgent do
  use ExAgent

  responsibilities do
    PingTestResponsibility
  end

  start
end

defmodule PongTestRespAgent do
  use ExAgent

  responsibilities do
    PongTestResponsibility 
  end

  initialize do
    &send(PingTestRespAgent.agent_name("ag1"), :inform, ping)
  end

  start
end

defmodule PingPongTestUseAgentTest do
  use ExUnit.Case

  test "it handle messages" do
    ping = PingTestRespAgent.create("ag1")
    pong = PongTestRespAgent.create("ag2")

    ExAgent.run_loop(ping)
    ExAgent.run_loop(pong)

    Process.sleep(200)
    Process.exit(ping, 0)
    Process.exit(pong, 0)
  end
end
