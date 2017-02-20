defmodule AgentHelper do
  require Logger

  def add_initial_beliefs(agent, beliefs) do
    initial_beliefs = prepare_initial_beliefs(beliefs)
    do_add_initial_beliefs(agent, initial_beliefs)
  end

  defp do_add_initial_beliefs(_, {:error, _}=beliefs) do
    beliefs
  end

  defp do_add_initial_beliefs(agent, beliefs) do
    ExAgent.add_beliefs(agent, beliefs)
  end

  def prepare_initial_beliefs(beliefs) do
    case check_beliefs(beliefs) do
      {:ok, beliefs} -> beliefs
      _ -> {:error, "The initial beleifs passed are not correct #{inspect(beliefs)}"}
    end
  end

  defp check_beliefs(beliefs) do
    non_beliefs = Enum.filter(beliefs, fn bel -> bel == :not_a_belief end)

    case non_beliefs do
      [] -> {:ok, Enum.map(beliefs, fn bel -> EventContent.content(bel, []) end)}
      _ -> :error
    end
  end

  def set_initial_as_intents(_, []) do
    Logger.info "\nNo Initial intent created"
  end

  def set_initial_as_intents(agent, initial) do
    intent =
      initial
      |> Intention.create(:initialize)

    ExAgent.add_intent(agent, intent)
    Logger.info "\nAdded initial beliefs/goals as intents"
  end

  def add_plan_rules(agent, plans) do
    ExAgent.add_plan_rules(agent, plans)
  end

  def add_recovery_handlers(agent, recovery_handlers) do
    ExAgent.add_recovery_handlers(agent, recovery_handlers)
  end

  def add_message_handlers(agent, message_handlers) do
    ExAgent.add_message_handlers(agent, message_handlers)
  end

  def add_responsibilities(agent, responsibilities) do
    add_initial_beliefs(agent, Responsibility.initial_beliefs(responsibilities))
    add_plan_rules(agent, Responsibility.plan_rules(responsibilities))
    add_message_handlers(agent, Responsibility.message_handlers(responsibilities))
    add_recovery_handlers(agent, Responsibility.recovery_handlers(responsibilities))
  end

end
