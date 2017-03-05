defmodule ExAgent.Registry do
  use GenServer

  def handle_call(:init, _from, state) do
    res = :ets.new(ExAgent.Registry, [:set, :protected, :named_table])
    {:reply, res, state}
  end

  def handle_call({:register, module, name, pid}, _from, state) do
    res = ExAgent.Registry
    |> :ets.insert({"full", module, name, pid})
    {:reply, res, state}
  end

  def handle_call({:un_register, module, name}, _from, state) do
    res = ExAgent.Registry 
    |> :ets.match_object({"full", module, name, :"_"})
    |> Enum.map(fn obj -> :ets.delete_object(ExAgent.Registry, obj) end)
    {:reply, res, state}
  end

  def handle_call({:un_register, pid}, _from, state) do
    res = ExAgent.Registry
    |> :ets.match_object({"full", :"_", :"_", pid})
    |> Enum.map(fn obj -> :ets.delete_object(ExAgent.Registry, obj) end)
    {:reply, res, state}
  end

  def handle_call({:find, module, name}, _from, state) do
    res = ExAgent.Registry
    |> :ets.match({"full", module, name, :"$1"}) |> prepare_return
    {:reply, res, state}
  end

  def handle_call({:find_by_name, name}, _from, state) do
    res = ExAgent.Registry
    |> :ets.match({"full", :"$1", name, :"$3"})
    |> Enum.map(fn [module, pid] -> {module, name, pid} end)
    {:reply, res, state}
  end

  def handle_call({:find_by_module, module}, _from, state) do
    res = ExAgent.Registry
    |> :ets.match({"full", module, :"$1", :"$2"})
    |> Enum.map(fn [name, pid] -> {module, name, pid} end)
    {:reply, res, state}
  end

  def handle_call(:all, _from, state) do
    res = :ets.match_object(ExAgent.Registry, {:"$1", :"_", :"_", :"_"})
    {:reply, res, state}
  end

  def init do
    if Process.whereis(__MODULE__) == nil do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
      GenServer.call(__MODULE__, :init)
    end
  end

  def register_agent(module, name, pid) do
    GenServer.call(__MODULE__, {:register, module, name, pid})
  end

  def unregister_agent(module, name) do
    GenServer.call(__MODULE__, {:un_register, module, name})
  end

  def unregister_agent(pid) do
    GenServer.call(__MODULE__, {:un_register, pid})
  end

  def find(module, name) do
    GenServer.call(__MODULE__, {:find, module, name})
  end

  def find_by_name(name) do
    GenServer.call(__MODULE__, {:find_by_name, name})
  end

  def find_by_module(module) do
    GenServer.call(__MODULE__, {:find_by_module, module})
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  defp prepare_return([]), do: :not_found
  defp prepare_return([h | _]), do: h |> hd

end
