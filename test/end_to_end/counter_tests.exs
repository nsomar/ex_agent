defmodule CounterAgent do
  use EXAgent

  initialize do
    +counter(5)
    !count
  end

  rule (+!count) when counter(0) do
    &print("DONE")
  end

  rule (+!count) when counter(X) do
    &print("Current " <> X)
    -counter(X)
    +counter(X - 1)
    !count
  end

  start
end

defmodule CounterAgentTest do
  use ExUnit.Case

  test "it parses the plans" do
    rules = CounterAgent.plan_rules |> IO.inspect
    assert rules |> Enum.count == 2
  end

  test "it parses the initializer" do
    initial = CounterAgent.initial
    initial |> IO.inspect
  end
end
