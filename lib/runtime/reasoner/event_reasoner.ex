defmodule Reasoner.Event do
  require Logger

  def select_event([]), do: {:no_event, []}
  def select_event(events) do
    [selected| rest] = events
    Logger.info fn -> "\nEvent:\n#{inspect(selected)}" end
    {selected, rest}
  end

  def build_new_events(:no_event, rest_events),
    do: rest_events
  def build_new_events(new_event, rest_events),
    do: rest_events ++ [new_event]
end
