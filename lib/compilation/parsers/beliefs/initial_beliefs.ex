defmodule InitialBeliefs do
  defstruct [:beliefs]
  @type t :: %RuleBody{instructions: tuple}

  def parse([do: statements]) do
    do_parse(statements)
  end

  defp do_parse(nil) do
    []
  end

  defp do_parse({:__block__, _, statements}) do
    statements
    |> Enum.map(&do_parse_item/1)
  end

  defp do_parse(statements) when is_tuple(statements) do
   [do_parse_item(statements)]
  end

  defp do_parse_item(statement) when is_tuple(statement) do
    Belief.parse(statement)
  end
end
