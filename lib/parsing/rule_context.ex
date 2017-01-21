defmodule RuleContext do

  defstruct [:contexts, :function]

  def parse(rule) do
    parsed = do_parse_rule_context(rule)
    # IO.inspect parsed
    contexts = Enum.filter(parsed, fn item -> !function?(item) end)
    functions = Enum.filter(parsed, fn item -> function?(item) end)

    %RuleContext{
      contexts: contexts,
      function: get_function(functions)
    }
  end

  defp get_function([function]),
  do: function

  defp get_function([]),
  do: nil

  defp get_function(_),
  do: {:error, "passing multiple context functions is invalid"}

  defp do_parse_rule_context({:when, _, [_, ctx]}) do
    [CommonRuleParsers.parse_event_test(ctx)]
    |> List.flatten
    |> Enum.map(&convert_to_model/1)
  end

  # Convert to model
  def convert_to_model({:test, test}), do: ContextFunction.create(test)
  def convert_to_model(item), do: item

  defp function?(%ContextFunction{}), do: true
  defp function?(_), do: false
end
