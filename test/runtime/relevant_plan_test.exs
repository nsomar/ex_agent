defmodule RelPlanAgent1 do
  use EXAgent

  initialize do end

  rule (+!buy(Car, Color)) when wants(Car) do end
  rule (+!buy(Car, Color)) when has(Car) && likes(Color) do end
  rule (+!buy(Car, Color)) when has(Car) && likes(Color, Alot) do end
  rule (+!has(CAR, X)) do end
  rule (+owns(:bmw)) do end
  rule (+owns(X)) do end
  rule (+!sell(Car)) when has(Car) && cost(Car, Price) && test Price > 1000 do end

  start
end

defmodule RelevantPlanTest do
  use ExUnit.Case

  describe "Relevant Plan" do

    test "it gets the relevant plans 1" do
      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_belief, content: {:owns, {:bmw}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      assert length(relevant) == 2

      assert relevant |> Enum.at(0) |> elem(1)  == []
      assert relevant |> Enum.at(1) |> elem(1)  == [X: :bmw]
    end

    test "it gets the relevant plans 2" do
      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_belief, content: {:owns, {:opel}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      assert length(relevant) == 1

      assert relevant |> Enum.at(0) |> elem(1)  == [X: :opel]
    end

    test "it gets the relevant plans 3" do
      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:has, {:opel, :red}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      assert length(relevant) == 1

      assert relevant |> Enum.at(0) |> elem(1)  == [CAR: :opel, X: :red]
    end

  end

  describe "Applicable Plans" do

    test "it gets applicable plans for simple rule without a function" do
      beliefs = [{:wants, {:bmw}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      applicable = RelevantPlan.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
    end

    test "it gets applicable plans for simple rule without a function when multiple beliefs match" do
      beliefs = [{:wants, {:bmw}}, {:wants, {:opel}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      applicable = RelevantPlan.applicable_plans(relevant, beliefs)
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

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      applicable = RelevantPlan.applicable_plans(relevant, beliefs)
      assert length(applicable) == 2
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
      assert applicable |> Enum.at(1) |> elem(1) == [[Car: :bmw, Color: :red, Alot: true]]
    end

     test "it gets applicable plans for simple rule without a function 2" do
      beliefs = [{:has, {:bmw}}, {:likes, {:red}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      applicable = RelevantPlan.applicable_plans(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red]]
    end

    test "it does not get plans that dont match the beliefs" do
      beliefs = [{:wants, {:opel}}]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:buy, {:bmw, :red}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      applicable = RelevantPlan.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get applicable plans for rule with a function when the function does not pass" do
      beliefs = [
        {:has, {:bmw}},
        {:cost, {:bmw, 100}},
      ]

      all_plans = RelPlanAgent1.plan_rules
      event = %Event{event_type: TriggerType.added_goal, content: {:sell, {:bmw}}}

      relevant = RelevantPlan.relavent_plans(all_plans, event)
      applicable = RelevantPlan.applicable_plans(relevant, beliefs)
      assert length(applicable) == 0
    end

  end

end
