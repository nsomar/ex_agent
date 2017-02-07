defmodule ContextFunctionTestCar do
  def color, do: :red
end

defmodule ContextFunctionTest do
  use ExUnit.Case

  test "it creats correct struct" do
    # rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y

    t =
      {{:&&, [line: 34],
        [{:>=, [line: 34],
          [{:__aliases__, [counter: 0, line: 34], [:Z]},
           {:__aliases__, [counter: 0, line: 34], [:Y]}]},
         {:==, [line: 34], [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]}}
    assert ContextFunction.create(t) ==
    %AstFunction{ast: {:&&, [],
      [{:>=, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:Y]}]},
       {:==, [], [{:__aliases__, [], [:Z]}, 2]}]}, number_of_params: 2,
     params: [:Z, :Y]}
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
    %AstFunction{ast: {{:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]}},
               number_of_params: 2, params: [:Z, :Y]}
    assert cf.ast == {:&&, [], [{:>, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:X]}]}, {:==, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:W]}]}]}
  end

  describe "Parameter checking" do

    test "it can check params are correct" do
      cf = %AstFunction{ast: {:&&, [line: 34],
                   [{:>=, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]},
                      {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                    {:==, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
                 number_of_params: 2, params: [:Z, :Y]}

      assert AstFunction.check_all_params_present(cf.params, [Y: 20, Z: 30]) == :ok
    end

    test "it can check params are correct even if extra params are given" do
      cf = %AstFunction{ast: {:&&, [line: 34],
                   [{:>=, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]},
                      {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                    {:==, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
                 number_of_params: 2, params: [:Z, :Y]}

      assert AstFunction.check_all_params_present(cf.params, [Y: 20, Z: 30, W: 20]) == :ok
    end

    test "it can check params are incorrect" do
      cf = %AstFunction{ast: {:&&, [line: 34],
                   [{:>=, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]},
                      {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                    {:==, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
                 number_of_params: 2, params: [:Z, :Y]}

      assert AstFunction.check_all_params_present(cf.params, [Y: 20, Z1: 30]) != :ok
    end

  end

  test "it prepares ast" do
    # Z >= Y && Z == 2

    cf = %AstFunction{ast: {:&&, [line: 34],
                 [{:>=, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]},
                    {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                  {:==, [line: 34],
                   [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
               number_of_params: 2, params: [:Z, :Y]}

    assert AstFunction.prepare_ast(cf.ast, cf.params, [Y: 20, Z: 30]) == {:&&, [], [{:>=, [], [30, 20]}, {:==, [], [30, 2]}]}
  end

  describe "Performing" do

    test "it prepares performs method" do
      # Z >= Y && Z == 2

      cf = %AstFunction{ast: {:&&, [line: 34],
                   [{:>=, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]},
                      {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                    {:==, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
                 number_of_params: 2, params: [:Z, :Y]}

      assert AstFunction.perform(cf, [Y: 1, Z: 2]) == true
    end

    test "it cant perform if params dont match" do
      # Z >= Y && Z == 2

      cf = %AstFunction{ast: {:&&, [line: 34],
                   [{:>=, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]},
                      {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                    {:==, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
                 number_of_params: 2, params: [:Z, :Y]}

      assert AstFunction.perform(cf, [Y: 1, W: 2]) == false
    end

    test "it performs if extra params are given" do
      # Z >= Y && Z == 2

      cf = %AstFunction{ast: {:&&, [line: 34],
                   [{:>=, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]},
                      {:__aliases__, [counter: 0, line: 34], [:Y]}]},
                    {:==, [line: 34],
                     [{:__aliases__, [counter: 0, line: 34], [:Z]}, 2]}]},
                 number_of_params: 2, params: [:Z, :Y]}

      assert AstFunction.perform(cf, [Y: 1, Z: 2, W: 2]) == true
    end

  end

  describe "perform or return var" do

    test "it performs if multiple vars" do
      ast = %AstFunction{ast: {:+, [], [{:__aliases__, [], [:X]}, {:__aliases__, [], [:Y]}]}, number_of_params: 2, params: [:X, :Y]}
      AstFunction.perform_or_var(ast, [])
    end

    test "it performs if single var and bound" do
      ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
      assert AstFunction.perform_or_var(ast, [X: 10]) == 10
    end

    test "it return var if not bound" do
      ast = %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}
      assert AstFunction.perform_or_var(ast, []) == :X
    end

    test "it performs if single bar and arithmatic" do
      ast = %AstFunction{ast: {:+, [], [{:__aliases__, [], [:X]}, 1]}, number_of_params: 1, params: [:X]}
      assert AstFunction.perform_or_var(ast, [X: 10]) == 11
    end

    test "it does not perform if function call" do

      ast = %AstFunction{ast: {{:., [line: 9],
     [{:__aliases__, [counter: 0, line: 9], [:ContextFunctionTestCar]}, :color]}, [], []},
   number_of_params: 0, params: []}
      assert AstFunction.perform_or_var(ast, [X: 10]) == :red
    end
  end

end
