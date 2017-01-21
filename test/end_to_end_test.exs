defmodule EndToEndTest do
  use ExUnit.Case

  test "It can define a full rule with event, context and body" do
    defmodule Test1 do
      use AgentRules

      rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y do
        +owns(X)
      end
    end
  end

end
