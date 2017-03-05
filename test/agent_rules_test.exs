defmodule EndToEndTest do
  use ExUnit.Case

  test "It can define a full rule with event, context and body" do
    defmodule Test1 do
      use ExAgent.Mod

      initialize do
      end

      rule (+!buy(X)) when cost(X, Y) && not money(Z) && something(true) && test Z >= Y do
        +owns(X)
        query(happy(N))
        &print(X)
      end

      rule (+owns(X)) do
        &print("I am really happy man!!!")
      end

      start()
    end

    events = Test1.plan_rules |> Enum.map(fn item -> item.head.trigger.event_type end)
    should_pass = Test1.plan_rules
    |> Enum.map(fn item -> item.head.context.contexts end)
    |> List.flatten
    |> Enum.map(fn item -> item.should_pass end)

    assert Test1.plan_rules |> Enum.count == 2
    assert should_pass == [true, false, true]
    assert events == [:added_goal, :added_belief]
  end

end
