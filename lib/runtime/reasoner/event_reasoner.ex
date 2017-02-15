defmodule Reasoner.Event do
  require Logger

  def select_event([]), do: {:no_event, []}
  def select_event(events) do
    [selected| rest] = events
    Logger.info fn -> "\nEvent:\n#{inspect(selected)}" end
    {selected, rest}
  end


  def merge_events(message_events, other_evens) do
    Logger.info "Merging events\nmessage_events #{inspect(message_events)}\nother_evens #{inspect(other_evens)}"
    message_events ++ other_evens
  end


  def build_new_events(:no_event, rest_events),
    do: rest_events
  def build_new_events(new_event, rest_events),
    do: rest_events ++ new_event
end
