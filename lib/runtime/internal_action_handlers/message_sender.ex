defmodule MessageSender do
  @callback send_message(String.t, atom, atom, [any]) :: any
end

defmodule DebugMessageSender do
  @behaviour MessageSender
  def send_message(recepient, performative, name, params) do
    {recepient, performative, name, params}
  end
end

defmodule ActualMessageSender do
  require Logger

  @behaviour MessageSender
  def send_message(pid, performative, name, params) when is_pid(pid) do
    Logger.info """
    Sending Message
    pid: #{inspect(pid)}
    Performative: #{inspect(performative)}
    Name: #{inspect(name)}
    Params: #{inspect(params)}
    """
    GenServer.cast(pid, {:message, {:message, {performative, name, params, self()}}})
  end

  def send_message(recepient, performative, name, params) do
    case Process.whereis(recepient) do
      nil ->
        Logger.warn "Cannot find process with name #{inspect(recepient)}"
      pid ->
        send_message(pid, performative, name, params)
    end
  end

end
