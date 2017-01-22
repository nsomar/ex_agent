defmodule EndToEndTest do
  use ExUnit.Case

  test "It can define a full rule with event, context and body" do
    defmodule Test1 do
      use EXAgent

      initialize do
      end

      rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y do
        +owns(X)
        query(happy(N))
        &print(X)
      end

      rule (+owns(X)) do
        &print("I am really happy man!!!")
      end

      start
    end

    events = Test1.plan_rules |> Enum.map(fn item -> item.head.trigger.event end)
    assert Test1.plan_rules |> Enum.count == 2
    assert events == [:added_belief, :added_goal]
  end

end
