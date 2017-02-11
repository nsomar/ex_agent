defmodule BeliefBase do

  use GenServer

  def handle_call({:add_belief, belief}, _from, beliefs) do
    {result, new} = do_add_belief(beliefs, belief)
    {:reply, result, new}
  end

  def handle_call({:remove_belief, belief}, _from, beliefs) do
    new = do_remove_belief(beliefs, belief)
    {:reply, new, new}
  end

  def handle_call({:test_belief, belief}, _from, beliefs) do
    new = do_test_belief(beliefs, belief)
    {:reply, new, new}
  end

  def handle_call(:get_beliefs, _from, beliefs) do
    {:reply, beliefs, beliefs}
  end

  def handle_call({:test_beliefs, belief, function}, _from, beliefs) do
    new = do_test_beliefs(beliefs, belief, function)
    {:reply, new, new}
  end

  def create(beliefs) do
    GenServer.start_link(__MODULE__, beliefs)
  end

  def add_belief(pid, belief) do
    GenServer.call(pid, {:add_belief, belief})
  end

  def remove_belief(pid, belief) do
    GenServer.call(pid, {:remove_belief, belief})
  end

  def beliefs(pid) do
    GenServer.call(pid, :get_beliefs)
  end

  def test_belief(pid, belief) do
    GenServer.call(pid, {:test_belief, belief})
  end

  def test_beliefs(pid, beliefs, function) do
    GenServer.call(pid, {:test_beliefs, beliefs, function})
  end

  def test_beliefs(pid, %Context{tests: tests, function: func}) do
    GenServer.call(pid, {:test_beliefs, tests, func})
  end

  def test_beliefs(pid, %Context{tests: tests}) do
    GenServer.call(pid, {:test_beliefs, tests, nil})
  end

  def test_beliefs(pid, beliefs) do
    GenServer.call(pid, {:test_beliefs, beliefs, nil})
  end

  def do_add_belief(beliefs, belief) when is_list(beliefs) and is_tuple(belief) do
    case has_belief(beliefs, belief) do
      true -> {:aleady_added, beliefs}
      false -> {:added, beliefs ++ [belief]}
    end
  end

  def do_remove_belief(beliefs, belief) when is_list(beliefs) and is_tuple(belief),
    do: Enum.filter(beliefs, fn b -> b != belief end)

  def do_test_belief(beliefs, test) when is_list(beliefs) and is_tuple(test),
    do: Unifier.unify(beliefs, test |> ContextBelief.from_belief) |> prepare_return

  def do_test_beliefs(beliefs, tests, fun) when is_list(beliefs) and is_list(tests) do
    Unifier.unify_list(beliefs, tests |> ContextBelief.from_beliefs, fun) |> prepare_return
  end

  defp has_belief(beliefs, belief) do
    Enum.any?(beliefs, fn bel -> bel == belief end)
  end

  defp do_test_beliefs(beliefs, tests) when is_list(beliefs) and is_list(tests),
    do: Unifier.unify_list(beliefs, tests |> ContextBelief.from_beliefs, nil) |> prepare_return

  defp prepare_return([h| _]), do: h
  defp prepare_return(_), do: :cant_unify

end
