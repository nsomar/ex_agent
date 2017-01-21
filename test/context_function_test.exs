defmodule ContextFunctionTest do
  use ExUnit.Case

  test "it can get the function params list for single statment" do
    # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y

    t =
      {:&&, [line: 34],
        [{:>=, [line: 34],
          [{:__aliases__, [counter: 0, line: 34], [:Z]},
           {:__aliases__, [counter: 0, line: 34], [:Y]}]},
         {:==, [line: 34], [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]}
    assert ContextFunction.get_params(t) == [:Z, :Y]
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
    assert ContextFunction.get_params(t) == [:Z, :Y, :W]
  end

  test "it creats correct struct" do
    # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y

    t =
      {{:&&, [line: 34],
        [{:>=, [line: 34],
          [{:__aliases__, [counter: 0, line: 34], [:Z]},
           {:__aliases__, [counter: 0, line: 34], [:Y]}]},
         {:==, [line: 34], [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]}}
    assert ContextFunction.create(t) ==
    %ContextFunction{ast: {:&&, [],
                 [{:>=, [],
                   [{:__aliases__, [], [:Z]},
                    {:__aliases__, [], [:Y]}]},
                  {:==, [],
                   [{:__aliases__, [], [:Z]}, 2]}]},
               number_of_params: 2, params: [:Z, :Y]}
  end

  test "it flatten the tests" do
    # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y

    t =
      {{:&&, [line: 41],
        [{:>, [line: 41],
          [{:__aliases__, [counter: 0, line: 41], [:Z]},
           {:__aliases__, [counter: 0, line: 41], [:X]}]},
         {:test, [line: 41],
          [{:==, [line: 41],
            [{:__aliases__, [counter: 0, line: 41], [:Z]},
             {:__aliases__, [counter: 0, line: 41], [:W]}]}]}]}}
    cf = ContextFunction.create(t)
    %ContextFunction{ast: {{:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]}},
               number_of_params: 2, params: [:Z, :Y]}
    assert cf.ast == {:&&, [], [{:>, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:X]}]}, {:==, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:W]}]}]}
  end

  test "it can check params are correct" do
    cf = %ContextFunction{ast: {:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
               number_of_params: 2, params: [:Z, :Y]}

    assert ContextFunction.check_all_params_present(cf, [Y: 20, Z: 30]) == :ok
  end

  test "it can check params are incorrect" do
    cf = %ContextFunction{ast: {:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
               number_of_params: 2, params: [:Z, :Y]}

    assert ContextFunction.check_all_params_present(cf, [Y: 20, Z1: 30]) != :ok
  end

  test "it prepares ast" do
    # Z >= Y && Z == 2

    cf = %ContextFunction{ast: {:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
               number_of_params: 2, params: [:Z, :Y]}

    assert ContextFunction.prepare_ast(cf, [Y: 20, Z: 30]) == {:&&, [], [{:>=, [], [30, 20]}, {:==, [], [30, 2]}]}
  end

  test "it prepares performs method" do
    # Z >= Y && Z == 2

    cf = %ContextFunction{ast: {:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
               number_of_params: 2, params: [:Z, :Y]}

    assert ContextFunction.perform(cf, [Y: 1, Z: 2]) == true
  end
end






























