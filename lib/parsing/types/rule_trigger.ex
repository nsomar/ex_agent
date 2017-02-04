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

defmodule CommonRuleParsers do

  def parse_event_test({:&&, _, tests}) do
    Enum.map(tests, &parse_event_test/1)
  end

  def parse_event_test({:!, _, [{belief, _, params}]}) do
    {parse_event_test(belief, params), false}
  end

  def parse_event_test({belief, _, params}) do
    {parse_event_test(belief, params), true}
  end

  defp parse_event_test(belief, params) do
    tuple =
      params
      |> Enum.map(&parse_event_parameter/1)
      |> List.to_tuple
    {belief, tuple}
  end

  defp parse_event_parameter({:__aliases__, _, [param]}), do: param
  defp parse_event_parameter(param), do: param

end
