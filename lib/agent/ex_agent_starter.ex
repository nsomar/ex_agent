defmodule ExAgent.Creator do
  def start_agent(module, name, linked \\ true) do
    ag = module.create(name, linked)
    module.run_loop(ag)
    ag
  end
end
