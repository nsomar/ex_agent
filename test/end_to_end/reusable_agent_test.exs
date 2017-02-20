defmodule ReusablePart1 do
  use ExAgent.Core

  rule (+!count) when counter(0) do end

  initial_beliefs do
    car(:green)
  end

  start
end

defmodule ReusablePart2 do
  use ExAgent.Core

  message(:inform, Sender, ping) do end

  initial_beliefs do
    car(:yellow)
  end

  start
end

defmodule ReusablePart3 do
  use ExAgent.Core

  message(:inform, Sender, ping) do end

  recovery (+bel1) do end

  start
end

defmodule ReusableAgent do
  use ExAgent
  # use Protocols.only(:asdsa, :aaaa)

  responsibilities do
    ReusablePart1
    ReusablePart2
    ReusablePart3
  end

  initial_beliefs do
    car(:red)
  end

  message(:inform1, Sender, ping) do end

  rule (+!count1) when counter(0) do end

  start
end

defmodule ReusableAgentTest  do
  use ExUnit.Case

  test "it parses reusabilities" do
    assert ReusableAgent.responsibilities ==
    %Responsibility{responsibilities: [:ReusablePart1, :ReusablePart2, :ReusablePart3]}
  end

  test "it has all the plan rules" do
    ag = ReusableAgent.create("ag")
    assert ExAgent.plan_rules(ag) |> Enum.count == 2
  end

  test "it has all the initial beliefs" do
    ag = ReusableAgent.create("ag")
    assert ExAgent.beliefs(ag) == [car: {:red}, car: {:green}, car: {:yellow}]
  end

  test "it has all the message handlers" do
    ag = ReusableAgent.create("ag")
    assert ExAgent.message_handlers(ag) |> Enum.count == 2
  end

  test "it has all the recoveries" do
    ag = ReusableAgent.create("ag")
    assert ExAgent.recovery_handlers(ag) |> Enum.count == 1
  end

end
