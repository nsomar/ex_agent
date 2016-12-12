
defmodule EXAgent do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def handle_call({:add_beleif, bel}, _from, state) do
    {:reply, :added, [bel | state]}
  end

  def handle_call(:get_beleifs, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:remove_belief, bel}, _from, state) do
    state
    |> Enum.filter(fn stored_bel -> stored_bel == bel end)
    |> IO.inspect

    {:removed, state, state}
  end

  def add_belief(bel) do
    GenServer.call(__MODULE__, {:add_beleif, bel})
  end

  def get_beliefs do
    GenServer.call(__MODULE__, :get_beleifs)
  end

  def remove_belief(bel) do
    GenServer.call(__MODULE__, {:remove_belief, bel})
  end

  def beliefs do

  end
end
