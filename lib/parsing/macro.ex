defmodule Parsing.Macro do

  def parse_beliefs([do: statements]) do
    statements |> do_parse_beliefs |> remove_non_beliefs
  end

  def parse_goals([do: statements]) do
    statements |> do_parse_goals |> remove_non_goals
  end

  # Parse Beliefs
  # -------------------
  defp do_parse_beliefs({:__block__, _, beliefs}) when is_list(beliefs) do
    Enum.map(beliefs, &do_parse_belief/1)
  end

  defp do_parse_beliefs(statements) when is_tuple(statements) do
   [do_parse_belief(statements)]
  end

  defp do_parse_belief({:!, _, _} = statements) when is_tuple(statements),
    do: :not_a_belief

  defp do_parse_belief({belief, _, params} = statements) when is_tuple(statements) do
    {belief, List.to_tuple(params)}
  end

  # Parse Beliefs
  # -------------------
  #
  defp do_parse_goals({:__block__, _, goals}) when is_list(goals) do
    Enum.map(goals, &do_parse_goal/1)
  end

  defp do_parse_goals(statements) when is_tuple(statements) do
   [do_parse_goal(statements)]
  end

  defp do_parse_goal({:!, _, [goal]}) do
    parse_single_goal(goal)
  end

  defp do_parse_goal(_) do
    :not_a_goal
  end

  defp parse_single_goal(goal) do
    case goal do
      {name, _, Elixir} -> {name, []}
      {name, _, params} -> {name, params}
      true -> :not_a_goal
    end
  end

  # Parse rule trigger
  # -------------------
  #
  def parse_trigger(trigger) do
    do_parse_trigger(trigger)
  end

  defp do_parse_trigger({{:+, _, [{:!, _, [event]}]}}),
    do: {TriggerType.added_goal, parse_event_test(event)}

  defp do_parse_trigger({{:+, _, [event]}}),
    do: {TriggerType.added_belief, parse_event_test(event)}

  defp do_parse_trigger({{:-, _, [{:!, _, [event]}]}}),
    do: {TriggerType.removed_goal, parse_event_test(event)}

  defp do_parse_trigger({{:-, _, [event]}}),
    do: {TriggerType.removed_belief, parse_event_test(event)}

  defp parse_event_parameter({:__aliases__, _, [param]}), do: param
  defp parse_event_parameter(param), do: param

  # Parse rule context
  # -------------------
  #
  def parse_rule_context(context) do
    do_parse_rule_context(context)
  end

  defp do_parse_rule_context({tests}) do
    [parse_event_test(tests)] |> List.flatten
  end

  def parse_event_test({:&&, _, tests}) do
    Enum.map(tests, &parse_event_test/1)
  end

  def parse_event_test({belief, _, params}) do
    # IO.inspect {belief, params}
    tuple =
      params
      |> Enum.map(&parse_event_parameter/1)
      |> List.to_tuple
    {belief, tuple}
  end

  defp remove_non_beliefs(beliefs),
    do: Enum.filter(beliefs, fn x -> x != :not_a_belief end)

  defp remove_non_goals(goals),
    do: Enum.filter(goals, fn x -> x != :not_a_goal end)

end
