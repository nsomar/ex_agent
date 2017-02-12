defmodule Reasoner.Message do
  def process_messages(messages) do
    messages |> Enum.map(fn msg -> Event.from_instruction(msg, []) end)
  end
end
