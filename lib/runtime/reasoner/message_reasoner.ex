defmodule Reasoner.Message do
  require Logger

  def process_messages(messages) do
    Logger.info "Processing messages\n#{inspect(messages)}"
    messages |> Enum.map(fn msg -> Event.from_instruction(msg, []) end)
  end
end
