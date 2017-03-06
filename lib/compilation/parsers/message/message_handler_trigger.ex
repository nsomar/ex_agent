defmodule MessageHandlerTrigger do

  defstruct [:performative, :message]
  @type t :: %MessageHandlerTrigger{performative: atom, message: tuple}

  def parse(performative, message), do: do_parse_trigger(performative, message)

  defp do_parse_trigger(performative, {:when, _, [trigger, _]}),
    do: parse(performative, trigger)

  defp do_parse_trigger(performative, event),
    do: %MessageHandlerTrigger{
      performative: performative,
      message: CommonRuleParsers.parse_event_test(event) |> elem(0)
    }

end
