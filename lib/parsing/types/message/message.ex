defmodule Message do
  defstruct [:performative, :name, :params, :from]
  @type t :: %Message{performative: atom, name: atom, params: [any]}

  def parse({:message, {performative, name, params, from}}) do
    %Message{
      performative: performative,
      name: name,
      params: params,
      from: from
    }
  end

  def parse(_), do: :not_a_message

  def message(%{name: name, params: params}) do
    {name, params |> List.to_tuple}
  end
end
