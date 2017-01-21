defmodule TriggerType do
  def added_belief, do: :added_belief
  def added_goal, do: :added_goal

  def removed_belief, do: :removed_belief
  def removed_goal, do: :removed_goal
end

defmodule Event do
  defstruct [:event_type, :content]

  def added_belief(belief),
    do: %Event{event_type: :added_belief, content: belief}

  def removed_belief(belief),
    do: %Event{event_type: :removed_belief, content: belief}

  def added_goal(goal),
    do: %Event{event_type: :added_goal, content: goal}

  def removed_goal(goal),
    do: %Event{event_type: :removed_goal, content: goal}

  def added_test_goal(goal),
    do: %Event{event_type: :added_test_goal, content: goal}

  def removed_test_goal(goal),
    do: %Event{event_type: :removed_test_goal, content: goal}
end
