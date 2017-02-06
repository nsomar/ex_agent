defmodule CommonInstructionParserTest do
  use ExUnit.Case

  describe "Parameters" do

    test "it can get the function params list for single statment" do
      # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y

      t =
        {:&&, [line: 34],
          [{:>=, [line: 34],
            [{:__aliases__, [counter: 0, line: 34], [:Z]},
             {:__aliases__, [counter: 0, line: 34], [:Y]}]},
           {:==, [line: 34], [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]}
      assert CommonInstructionParser.parse_vars(t) == [:Z, :Y]
    end

    test "it can get the function params list for multiple statment" do
      # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y && W == 2

      t =
        {:&&, [line: 34],
              [{:>=, [line: 34],
                [{:__aliases__, [counter: 0, line: 34], [:Z]},
                 {:__aliases__, [counter: 0, line: 34], [:Y]}]},
               {:==, [line: 34],
                [{:__aliases__, [counter: 0, line: 34], [:W]}, 2]}]}
      assert CommonInstructionParser.parse_vars(t) == [:Z, :Y, :W]
    end

    test "it can get the function params list for multiple statment with atoms" do
      # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y && W == 2

      t =
        {:&&, [line: 34],
              [{:>=, [line: 34],
                [{:__aliases__, [counter: 0, line: 34], [:Z]},
                 {:__aliases__, [counter: 0, line: 34], [:Y]}]},
               {:==, [line: 34],
                [{:__aliases__, [counter: 0, line: 34], [:red]}, 2]}]}
      assert CommonInstructionParser.parse_vars(t) == [:Z, :Y]
    end

  end
end
