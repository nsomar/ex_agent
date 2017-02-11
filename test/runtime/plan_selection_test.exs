defmodule RelPlanAgent1 do
  use ExAgent

  initialize do end

  rule (+!has(CAR, X)) do end
  rule (+owns(:bmw)) do end
  rule (+owns(X)) do end
  rule (+!sell(Car)) when has(Car) && cost(Car, Price) && test Price > 1000 do end
  rule (+!sell(Car)) when has(Car) && color(Car, Value) && test Value == :red do end

  rule (+!buy(Car, Color)) when wants(Car) do end
  rule (+!buy(Car, Color)) when has(Car) && likes(Color) do end
  rule (+!buy(Car, Color)) when has(Car) && likes(Color, Alot) do end

  rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
  rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
  rule (+!buy4(:bmw, Color)) when !has(:bmw) && cost(:bmw, Money) && money(Pocket) && test Pocket > Money do end

  rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket)  && !has(Car) && test Pocket > Money * 2 do end

  rule (+!buy6(Car)) when wishlist(Wish) && !has(Car) && test String.upcase(Car) == String.upcase(Wish) do end

  start
end

defmodule PlanSelectionTest do
  use ExUnit.Case

  describe "Relevant Plan" do

    test "it gets the relevant plans 1" do
      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_belief, content: {:owns, {:bmw}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      assert length(relevant) == 2

      assert relevant |> Enum.at(0) |> elem(1)  == []
      assert relevant |> Enum.at(1) |> elem(1)  == [X: :bmw]
    end

    test "it gets the relevant plans 2" do
      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_belief, content: {:owns, {:opel}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      assert length(relevant) == 1

      assert relevant |> Enum.at(0) |> elem(1)  == [X: :opel]
    end

    test "it gets the relevant plans 3" do
      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:has, {:opel, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      assert length(relevant) == 1

      assert relevant |> Enum.at(0) |> elem(1)  == [CAR: :opel, X: :red]
    end

  end

  describe "Applicable Plans" do

    test "it gets applicable plans for simple rule without a function" do
      beliefs = [{:wants, {:bmw}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
    end

    test "it gets applicable plans for simple rule without a function when multiple beliefs match" do
      beliefs = [{:wants, {:bmw}}, {:wants, {:opel}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
    end

    test "it gets applicable plans for simple rule without a function when multiple beliefs match 2" do
      beliefs = [
        {:wants, {:bmw}},
        {:wants, {:opel}},
        {:has, {:bmw}},
        {:likes, {:red, true}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 2
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
      assert applicable |> Enum.at(1) |> elem(1) == [[Car: :bmw, Color: :red, Alot: true]]
    end

     test "it gets applicable plans for simple rule without a function 2" do
      beliefs = [{:has, {:bmw}}, {:likes, {:red}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
    end

    test "it does not get plans that dont match the beliefs" do
      beliefs = [{:wants, {:opel}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get applicable plans for rule with a function when the function does not pass" do
      beliefs = [
        {:has, {:bmw}},
        {:cost, {:bmw, 100}},
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:sell, {:bmw}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get applicable plans for rule with a function when the function does not pass 2" do
      beliefs = [
        {:has, {:bmw}},
        {:color, {:bmw, :green}},
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:sell, {:bmw}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it gets applicable plans for rule with a function when the function passes" do
      beliefs = [
        {:has, {:bmw}},
        {:cost, {:bmw, 10000}},
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:sell, {:bmw}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Price: 10000]]
    end

    test "it gets applicable plans for rule with a function when the function passes 2" do
      beliefs = [
        {:has, {:bmw}},
        {:color, {:bmw, :red}},
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:sell, {:bmw}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Value: :red]]
    end

  end

  describe "Applicable Plans With False tests" do

     test "it gets the car if has enough money and car is not owned" do
      # rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
      beliefs = [
        {:money, {1000}},
        {:cost, {:bmw, 1000}},
        {:has, {:bmw}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy2, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get the car if has enough money and car is owned" do
      # rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
      beliefs = [
        {:money, {1000}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy2, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Color: :red, Money: 1000]]
    end

  end

  describe "Applicable Plans With False tests and function" do

    test "it gets the car if has enough money" do
      # rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
      beliefs = [
        {:money, {10000}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy3, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Color: :red, Money: 1000, Pocket: 10000]]
    end

    test "it does not get car if does not have enough money" do
      # rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
      beliefs = [
        {:money, {100}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy3, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

  end

  describe "Applicable Plans With False tests and function and constants" do

    test "it gets the car if has enough money" do
      # rule (+!buy4(:bmw, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
      beliefs = [
        {:money, {10000}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy4, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Color: :red, Money: 1000, Pocket: 10000]]
    end

  end

  describe "Applicable Plans With False tests and arithmatic" do

    test "it gets the car if has more than double the price" do
      # rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket) && test Pocket > Money && !has(Car) do end
      beliefs = [
        {:money, {2001}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy5, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Color: :red, Money: 1000, Pocket: 2001]]
    end

    test "it does not get the car if has more less than double the price" do
      # rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket) && test Pocket > Money && !has(Car) do end
      beliefs = [
        {:money, {1999}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy5, {:bmw, :red}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

  end

  describe "Applicable Plans With False tests and arithmatic" do

    test "it gets the car if its in the wish list" do
      # rule (+!buy6(Car)) when wishlist(Wish) && !has(Car) && test String.capitalize(Car) == String.capitalize(Wish) * 2 do end
      beliefs = [
        {:wishlist, {"BMW"}},
        {:has, {"opel"}}
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy6, {"bmw"}}}

      relevant = PlanSelection.relavent_plans(all_plans, event)
      applicable = PlanSelection.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: "bmw", Wish: "BMW"]]
    end

  end

end
