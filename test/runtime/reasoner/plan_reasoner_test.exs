defmodule PlanReasonerTestAgent do
  use ExAgent.Mod

  message :inform, sender, echo(MSG) do end
  rule (+!has(CAR)) do end

  start()
end

defmodule PlanReasonerTest do
  use ExUnit.Case

  test "it selects message for message event" do
    event = %Event{content: %Message{name: :echo, params: ["hello"], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

    {:ok, sel, _} = Reasoner.Plan.select_handler(PlanReasonerTestAgent.plan_rules, PlanReasonerTestAgent.message_handlers, [], event)
    assert sel.head.trigger.performative == :inform
  end

  test "it selects goal for goal event" do
    event =  %Event{event_type: TriggerType.added_goal, content: {:has, {:opel}}}

    {:ok, sel, _} = Reasoner.Plan.select_handler(PlanReasonerTestAgent.plan_rules, PlanReasonerTestAgent.message_handlers, [{:has, {:opel}}], event)
    assert sel.head.trigger.event_type == :added_goal
  end
end
