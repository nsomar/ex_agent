defmodule PingTestAgent do
  use ExAgent.Mod

  message(:inform, Sender, ping) do
    &print("PING")
    &send(Sender, :inform, pong)
  end

  start()
end

defmodule PongTestAgent do
  use ExAgent.Mod

  initialize do
    &send(PingTestAgent.agent_name("ag1"), :inform, ping)
  end

  message(:inform, Sender, pong) do
    &print("PONG")
    &send(Sender, :inform, ping)
  end

  start()
end

defmodule PingPongTestAgentTest do
  use ExUnit.Case

  test "it handle messages" do
    ping = PingTestAgent.create("ag1")
    pong = PongTestAgent.create("ag2")

    ExAgent.Mod.run_loop(ping)
    ExAgent.Mod.run_loop(pong)

    Process.sleep(200)
    Process.exit(ping, 0)
    Process.exit(pong, 0)
  end

end
