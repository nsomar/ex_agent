defmodule PingTestAgent do
  use ExAgent

  message(:inform, Sender, ping) do
    &print("PING")
    &send(Sender, :inform, pong)
  end

  start
end

defmodule PongTestAgent do
  use ExAgent

  initialize do
    &send(PingTestAgent.agent_name("ag1"), :inform, ping)
  end

  message(:inform, Sender, pong) do
    &print("PONG")
    &send(Sender, :inform, ping)
  end

  start
end

defmodule PingPongTestAgentTest do
  use ExUnit.Case

  test "it handle messages" do
    ping = PingTestAgent.create("ag1")
    pong = PongTestAgent.create("ag2")

    ExAgent.run_loop(ping)
    ExAgent.run_loop(pong)

    Process.sleep(200)
    Process.exit(ping, 0)
    Process.exit(pong, 0)
  end

end
