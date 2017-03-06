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
    ExAgent.Mod.add_beliefs(agent, beliefs)
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

    ExAgent.Mod.add_intent(agent, intent)
    Logger.info "\nAdded initial beliefs/goals as intents"
  end

  def add_plan_rules(agent, plans) do
    ExAgent.Mod.add_plan_rules(agent, plans)
  end

  def add_recovery_handlers(agent, recovery_handlers) do
    ExAgent.Mod.add_recovery_handlers(agent, recovery_handlers)
  end

  def add_message_handlers(agent, message_handlers) do
    ExAgent.Mod.add_message_handlers(agent, message_handlers)
  end

  def add_roles(agent, roles) do
    add_initial_beliefs(agent, Role.initial_beliefs(roles))
    add_plan_rules(agent, Role.plan_rules(roles))
    add_message_handlers(agent, Role.message_handlers(roles))
    add_recovery_handlers(agent, Role.recovery_handlers(roles))
  end

end
