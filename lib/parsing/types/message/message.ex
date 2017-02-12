defmodule Message do
  defstruct [:performative, :name, :params]
  @type t :: %Message{performative: atom, name: atom, params: [any]}

  def parse({:message, {performative, name, params}}) do
    %Message{
      performative: performative,
      name: name,
      params: params
    }
  end

  def parse(_), do: :not_a_message
end
