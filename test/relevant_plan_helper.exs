defmodule RelPlanAgent1 do
  use ExAgent.Mod

  initialize do
  end

  rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y do
    +owns(X)
    query(happy(N))
    &print(X)
  end

  rule (+owns(X)) do
    &print("I am really happy man!!!")
  end

  start
end
