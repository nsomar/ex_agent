defmodule Intention do
  defstruct [:instructions, :bindings, :plan]

  def from_events(events) do
    %Intention{
      instructions: events |> Enum.reverse,
      bindings: [],
      plan: nil
    }
  end
end
