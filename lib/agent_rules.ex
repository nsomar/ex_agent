defmodule AgentRules do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

    end
  end

  defmacro rule(head, body) do
    r = Rule.parse(head, body)
    IO.inspect(r.body)
    1
  end
end
