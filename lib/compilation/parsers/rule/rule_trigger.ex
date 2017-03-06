defmodule RuleTrigger do

  defstruct [:event_type, :content]
  @type t :: %RuleTrigger{event_type: atom, content: tuple}

  def parse(rule), do: do_parse_trigger(rule)

  defp do_parse_trigger({:+, _, [{:!, _, [event]}]}),
    do: %RuleTrigger{
      event_type: TriggerType.added_goal,
      content: CommonRuleParsers.parse_event_test(event) |> elem(0)
    }

  defp do_parse_trigger({:+, _, [event]}),
    do: %RuleTrigger{
      event_type: TriggerType.added_belief,
      content: CommonRuleParsers.parse_event_test(event) |> elem(0)
    }

  defp do_parse_trigger({:-, _, [{:!, _, [event]}]}),
    do: %RuleTrigger{
      event_type: TriggerType.removed_goal,
      content: CommonRuleParsers.parse_event_test(event) |> elem(0)
    }

  defp do_parse_trigger({:-, _, [event]}),
    do: %RuleTrigger{
      event_type: TriggerType.removed_belief,
      content: CommonRuleParsers.parse_event_test(event) |> elem(0)
    }

  defp do_parse_trigger({:when, _, [trigger, _]}),
    do: parse(trigger)

end
