defmodule RuleTrigger do

  defstruct [:event, :trigger]

  def parse(rule), do: do_parse_trigger(rule)

  defp do_parse_trigger({:+, _, [{:!, _, [event]}]}),
    do: %RuleTrigger{
      event: TriggerType.added_goal,
      trigger: CommonRuleParsers.parse_event_test(event)
    }

  defp do_parse_trigger({:+, _, [event]}),
    do: %RuleTrigger{
      event: TriggerType.added_belief,
      trigger: CommonRuleParsers.parse_event_test(event)
    }

  defp do_parse_trigger({:-, _, [{:!, _, [event]}]}),
    do: %RuleTrigger{
      event: TriggerType.removed_goal,
      trigger: CommonRuleParsers.parse_event_test(event)
    }

  defp do_parse_trigger({:-, _, [event]}),
    do: %RuleTrigger{
      event: TriggerType.removed_belief,
      trigger: CommonRuleParsers.parse_event_test(event)
    }

  defp do_parse_trigger({:when, _, [trigger, _]}),
    do: parse(trigger)

end

defmodule CommonRuleParsers do

  def parse_event_test({:&&, _, tests}) do
    Enum.map(tests, &parse_event_test/1)
  end

  def parse_event_test({belief, _, params}) do
    # IO.inspect {belief, params}
    tuple =
      params
      |> Enum.map(&parse_event_parameter/1)
      |> List.to_tuple
    {belief, tuple}
  end

  defp parse_event_parameter({:__aliases__, _, [param]}), do: param
  defp parse_event_parameter(param), do: param

end
