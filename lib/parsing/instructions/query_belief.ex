defmodule QueryBelief do
  defstruct [:b]

  def parse({:query, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %QueryBelief{
      b: {name, params |> CommonInstructionParser.parse_params |> List.to_tuple}
    }
  end
end
