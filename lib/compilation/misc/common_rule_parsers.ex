defmodule CommonRuleParsers do

  def parse_event_test({:&&, _, tests}) do
    Enum.map(tests, &parse_event_test/1)
  end

  def parse_event_test({:not, _, [{statement, _, params}]}) do
    {parse_event_test(statement, params), false}
  end

  def parse_event_test({statement, _, params}) do
    {parse_event_test(statement, params), true}
  end

  defp parse_event_test(statement, nil), do: {statement, {}}
  defp parse_event_test(statement, params) do
    tuple =
      params
      |> Enum.map(&parse_event_parameter/1)
      |> List.to_tuple
    {statement, tuple}
  end

  defp parse_event_parameter({:__aliases__, _, [param]}), do: param
  defp parse_event_parameter(param), do: param

end
