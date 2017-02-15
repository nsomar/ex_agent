defmodule Intention do
  defstruct [:instructions, :bindings, :plan, :event]

  def from_instruction(instructions, event) do
    %Intention{
      event: event,
      instructions: instructions |> Enum.reverse,
      bindings: [],
      plan: nil
    }
  end
end
