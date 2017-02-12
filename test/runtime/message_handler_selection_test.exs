defmodule RelPlanAgent2 do
  use ExAgent

  message :inform, sender, echo("hello") do end
  # rule (+owns(:bmw)) do end
  # rule (+owns(X)) do end
  # rule (+!sell(Car)) when has(Car) && cost(Car, Price) && test Price > 1000 do end
  # rule (+!sell(Car)) when has(Car) && color(Car, Value) && test Value == :red do end

  # rule (+!buy(Car, Color)) when wants(Car) do end
  # rule (+!buy(Car, Color)) when has(Car) && likes(Color) do end
  # rule (+!buy(Car, Color)) when has(Car) && likes(Color, Alot) do end

  # rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
  # rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
  # rule (+!buy4(:bmw, Color)) when !has(:bmw) && cost(:bmw, Money) && money(Pocket) && test Pocket > Money do end

  # rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket)  && !has(Car) && test Pocket > Money * 2 do end

  # rule (+!buy6(Car)) when wishlist(Wish) && !has(Car) && test String.upcase(Car) == String.upcase(Wish) do end

  start
end

defmodule MessageHandlerSelectionTest do
  use ExUnit.Case

  test "aaa" do
    all_plans = RelPlanAgent2.message_handlers
    # event = %Event{event_type: TriggerType.added_belief, content: {:owns, {:bmw}}}

    # relevant = PlanSelection.relavent_plans(all_plans, event)
    # assert length(relevant) == 2

    # assert relevant |> Enum.at(0) |> elem(1)  == []
    # assert relevant |> Enum.at(1) |> elem(1)  == [X: :bmw]
  end
end
