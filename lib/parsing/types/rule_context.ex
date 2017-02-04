defmodule RuleContext do

  defstruct [:contexts, :function]
  @type t :: %RuleContext{contexts: [ContextBelief.t], function: (any -> any)}

  def parse(rule) do
    parsed = do_parse_rule_context(rule)

    contexts =
      parsed
      |> Enum.filter(fn item -> !function?(item) end)

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

  defp do_parse_rule_context(_) do
    []
  end

  # Convert to model
  def convert_to_model({{:test, test}, _}), do: ContextFunction.create(test)
  def convert_to_model({item, should_pass}), do: ContextBelief.create(item, should_pass)

  defp function?(%ContextFunction{}), do: true
  defp function?(_), do: false
end
