defmodule UnifierTest do
  use ExUnit.Case

  doctest Unifier
  @b [
    {:is, {:omar, :strong}},
    {:is, {:omar, :big}},
    {:is, {:car, :red}},
    {:is, {:dog, :yellow}}
  ]

  @b2 [
    {:car, {:cost, 1000}},
    {:car, {:weight, 20000}},
    {:car, {:color, :red}},
    {:car, {:speed, 1000}}
  ]

  @bwithmoney [
    {:car, {:cost, 1000}},
    {:car, {:weight, 20000}},
    {:car, {:color, :red}},
    {:car, {:speed, 1000}},
    {:money, {2000}},
    {:money, {:spending, 1400}}
  ]

  @bcosts [
    {:cost, {:car, 1000}},
    {:cost, {:iphone, 500}},
    {:color, {:iphone, :black}},
    {:color, {:car, :red}},
    {:speed, {:car, 1000}},
    {:money, {1000}},
  ]

  describe "unify single test" do

    test "It can unify a beleif" do
      test = ContextBelief.create({:is, {:omar, :strong}}, true)
      assert Unifier.unify(@b, test) == [[], :cant_unify, :cant_unify, :cant_unify]
    end

    # test "It can unify a beleif that should not pass" do
    #   test = ContextBelief.create({:is, {:omar, :strong}}, false)
    #   assert Unifier.unify(@b, test) == [:cant_unify, [], [], []]
    # end

    test "It returns not_found if not found" do
      test = ContextBelief.create({:is, {:omar1, :strong}}, true)
      assert Unifier.unify(@b, test) == [:cant_unify, :cant_unify, :cant_unify, :cant_unify]
    end

    test "it returns error when wrong params" do
      assert Unifier.unify_tuples(@b, :omar) == :cant_unify
      assert Unifier.unify_tuples(:aaa, {:omar}) == :cant_unify
    end

    test "it cant unify tuples of different length" do
      test = ContextBelief.create({1, 2}, true)
      assert Unifier.unify_tuples({1}, test) == :cant_unify
    end

    test "unifies tuples with constats" do
      l = {:omar, :red}
      r = {:omar, :red}
      res = Unifier.unify_tuples(l, r)
      assert res  == []
    end

    test "unifies tuples with variables" do
      l = {:omar, :red}
      r = {:omar, :X}
      res = Unifier.unify_tuples(l, r)
      assert res  == [X: :red]
    end

    test "unifies tuples with var and consts" do
      l = {:omar, :cost, 100}
      r = {:omar, :X, 100}
      res  = Unifier.unify_tuples(l, r)
      assert res == [X: :cost]
    end

    test "unifies tuples with multiple vars" do
      l = {:omar, :cost, 100}
      r = {:omar, :X, :Y}
      res = Unifier.unify_tuples(l, r)
      assert res == [X: :cost, Y: 100]
    end

    test "unifies tuples with multiple vars and consts" do
      l = {:omar, :cost, 100, :dollars}
      r = {:omar, :X, :Y, :dollars}
      res = Unifier.unify_tuples(l, r)
      assert res== [X: :cost, Y: 100]
    end

    test "fails to unify tuples with multiple vars and consts if last element does not match" do
      l = {:omar, :cost, 100, :dollars, :a}
      r = {:omar, :X, :Y, :dollars, :b}
      res = Unifier.unify_tuples(l, r)
      assert res == :cant_unify
    end

    test "unifies beliefs that match" do
      l = {:is, {:omar, :red}}
      r = {:is, {:omar, :red}}
      res = Unifier.unify_tuples(l, r)
      assert res  == []
    end

    test "unifies beliefs that match with variable" do
      l = {:is, {:omar, :red}}
      r = {:is, {:omar, X}}
      res = Unifier.unify_tuples(l, r)
      assert res  == [{X, :red}]
    end
  end

  describe "Unify with beliefs that should pass" do
    test "returns cant unify for beleifs that cant unify" do
      test = ContextBelief.create({:is, {:omar, :red}}, true)

      res = Unifier.unify(@b, test) |> remove_original
      assert res == [:cant_unify, :cant_unify, :cant_unify, :cant_unify]
    end

    test "unifies a tuple in a beleif without vars" do
      test = ContextBelief.create({:is, {:omar, :big}}, true)

      res = Unifier.unify(@b, test) |> remove_original
      assert res == [:cant_unify, [], :cant_unify, :cant_unify]
    end

    test "unifies a tuple in a beleif with a var" do
      test = ContextBelief.create({:is, {:omar, :X}}, true)

      res = Unifier.unify(@b, test) |> remove_original
      assert res == [[X: :strong], [X: :big], :cant_unify, :cant_unify]
    end

    test "unifies a tuple in a beleif with only vars" do
      test = ContextBelief.create({:is, {:X, :Y}}, true)

      res = Unifier.unify(@b, test) |> remove_original
      assert res == [[X: :omar, Y: :strong], [X: :omar, Y: :big], [X: :car, Y: :red], [X: :dog, Y: :yellow]]
    end

    test "unifies a tuple in a beleif with var and constant" do
      test = ContextBelief.create({:is, {:X, :red}}, true)

      res = Unifier.unify(@b, test) |> remove_original
      assert res == [:cant_unify, :cant_unify, [X: :car], :cant_unify]
    end

    test "unifies a tuple in a beleif with vars and constants" do
      test = ContextBelief.create({:car, {:X, 1000}}, true)

      res = Unifier.unify(@b2, test) |> remove_original
      assert res == [[X: :cost], :cant_unify, :cant_unify, [X: :speed]]
    end

    test "unifies a tuple in a beleif with multiple variables" do
      test = ContextBelief.create({:car, {:X, :Y}}, true)

      res = Unifier.unify(@b2, test) |> remove_original
      assert res == [[X: :cost, Y: 1000], [X: :weight, Y: 20000], [X: :color, Y: :red], [X: :speed, Y: 1000]]
    end

    test "unifies a tuple in a beleif with ending vars" do
      test = ContextBelief.create({:car, {:cost, :Y}}, true)

      res = Unifier.unify(@b2, test) |> remove_original
      assert res == [[Y: 1000], :cant_unify, :cant_unify, :cant_unify]
    end

    test "returns the original beleif" do
      test = ContextBelief.create({:car, {:X, 1000}}, true)

      res = Unifier.unify(@b2, test)
      assert res == [[X: :cost], :cant_unify, :cant_unify, [X: :speed]]
    end

    test "test it cleans out the wrong results" do
      test = ContextBelief.create({:car, {:cost, :Y}}, true)

      res = Unifier.unify(@b2, test) |> Unifier.remove_ununified
      assert res == [[Y: 1000]]
    end
  end

  # describe "Unify with beliefs that should not pass" do
  #     test "returns cant unify for beleifs that cant unify" do
  #       test = ContextBelief.create({:is, {:omar, :red}}, false)

  #       res = Unifier.unify(@b, test) |> remove_original
  #       assert res == [[], [], [], []]
  #     end

  #     test "unifies a tuple in a beleif without vars" do
  #       test = ContextBelief.create({:is, {:omar, :big}}, false)

  #       res = Unifier.unify(@b, test) |> remove_original
  #       assert res == [[], :cant_unify, [], []]
  #     end

  #     test "unifies a tuple in a beleif with a var" do
  #       test = ContextBelief.create({:is, {:omar, :X}}, false)

  #       res = Unifier.unify(@b, test) |> remove_original
  #       assert res == [:cant_unify, :cant_unify, [], []]
  #     end

  #     test "unifies a tuple in a beleif with only vars" do
  #       test = ContextBelief.create({:is, {:X, :Y}}, false)

  #       res = Unifier.unify(@b, test) |> remove_original
  #       assert res == [:cant_unify, :cant_unify, :cant_unify, :cant_unify]
  #     end

  #     test "unifies a tuple in a beleif with var and constant" do
  #       test = ContextBelief.create({:is, {:X, :red}}, false)

  #       res = Unifier.unify(@b, test) |> remove_original
  #       assert res == [[], [], :cant_unify, []]
  #     end

  #     test "unifies a tuple in a beleif with vars and constants" do
  #       test = ContextBelief.create({:car, {:X, 1000}}, false)

  #       res = Unifier.unify(@b2, test) |> remove_original
  #       assert res == [:cant_unify, [], [], :cant_unify]
  #     end

  #     test "unifies a tuple in a beleif with multiple variables" do
  #       test = ContextBelief.create({:car, {:X, :Y}}, false)

  #       res = Unifier.unify(@b2, test) |> remove_original
  #       assert res == [:cant_unify, :cant_unify, :cant_unify, :cant_unify]
  #     end

  #     test "unifies a tuple in a beleif with ending vars" do
  #       test = ContextBelief.create({:car, {:cost, :Y}}, false)

  #       res = Unifier.unify(@b2, test) |> remove_original
  #       assert res == [:cant_unify, [], [], []]
  #     end

  #     test "returns the original beleif" do
  #       test = ContextBelief.create({:car, {:X, 1000}}, false)

  #       res = Unifier.unify(@b2, test)
  #       assert res == [:cant_unify, [], [], :cant_unify]
  #     end

  #     test "test it cleans out the wrong results" do
  #       test = ContextBelief.create({:car, {:cost, :Y}}, false)

  #       res = Unifier.unify(@b2, test) |> Unifier.remove_ununified
  #       assert res == [[], [], []]
  #     end
  # end

  describe "unify muliple test" do

    test "test it fails to unify if first cant be unified" do
      tests = [
        ContextBelief.create({:car, {:cost, 100011}}, true),
        ContextBelief.create({:car, {:color, :red}}, true)
      ]
      res = Unifier.unify_list(@b2, tests)
      assert res == :cant_unify
    end

    test "test it fails to unify if second cant be unified" do
      tests = [
        ContextBelief.create({:car, {:cost, 1000}}, true),
        ContextBelief.create({:car, {:color, :red1}}, true)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == :cant_unify
    end

    test "test it matches multiple tests" do
      tests = [
        ContextBelief.create({:car, {:cost, 1000}}, true),
        ContextBelief.create({:car, {:color, :red}}, true)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[]]
    end

    test "test it matches multiple tests with one varible" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :red}}, true)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[X: 1000]]
    end

    test "test it matches multiple tests with two varible" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :Y}}, true)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[X: 1000, Y: :red]]
    end

    test "test it matches multiple tests with multiple varible" do
      tests = [
        ContextBelief.create({:car, {:X1, :X2}}, true),
        ContextBelief.create({:money, {:Y}}, true)
      ]

      res = Unifier.unify_list(@bwithmoney, tests)
      assert res == [[X1: :cost, X2: 1000, Y: 2000], [X1: :weight, X2: 20000, Y: 2000], [X1: :color, X2: :red, Y: 2000], [X1: :speed, X2: 1000, Y: 2000]]
    end

    test "test it binds variable and reuses it" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:Y}}, true)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == [[X: :car, Y: 1000]]
    end

    test "it binds variable and reuses it and return cant unify if not possible" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money1, {:Y}}, true)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == :cant_unify
    end

    test "it binds difficult combinations" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:color, {:X, :Z}}, true)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == [[X: :car, Y: 1000, Z: :red], [X: :iphone, Y: 500, Z: :black]]
    end

    test "it binds three combinations" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:Y}}, true),
        ContextBelief.create({:color, {:X, :Z}}, true)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == [[X: :car, Y: 1000, Z: :red]]
    end

    test "it binds three combinations order of test does not matter" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:color, {:X, :Z}}, true),
        ContextBelief.create({:money, {:Y}}, true),
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == [[X: :car, Y: 1000, Z: :red]]
    end

    test "it binds three combinations and returns cant_unify if wrong" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:Y}}, true),
        ContextBelief.create({:color, {:X, :blue}}, true)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == :cant_unify
    end

  end

  describe "unify list with negative tests" do

    test "test it matches multiple tests and fails if should not pass" do
      tests = [
        ContextBelief.create({:car, {:cost, 1000}}, true),
        ContextBelief.create({:car, {:color, :red}}, false)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == :cant_unify
    end

    test "test it matches multiple tests and succeed if can pass" do
      tests = [
        ContextBelief.create({:car, {:cost, 1000}}, true),
        ContextBelief.create({:car, {:color, :red1}}, false)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[]]
    end

    test "test it fails to unify if second cant be unified" do
      tests = [
        ContextBelief.create({:car, {:cost, 1000}}, true),
        ContextBelief.create({:car, {:color, :red1}}, true),
        ContextBelief.create({:car, {:color, :red1}}, false)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == :cant_unify
    end

    test "test it matches multiple tests with one varible and test that does not pass" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :red}}, false)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == :cant_unify
    end

    test "test it matches multiple tests with one varible and test that passes" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :blue}}, false)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[X: 1000]]
    end

    test "test it matches multiple tests with two varible" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :Y}}, true)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[X: 1000, Y: :red]]
    end

    test "test it matches multiple tests with two varible with a test that does not pass" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:cost, 22}}, false),
        ContextBelief.create({:car, {:color, :Y}}, true)
      ]

      res = Unifier.unify_list(@b2, tests)
      assert res == [[X: 1000, Y: :red]]
    end

    test "test it binds variable and reuses it and return false for the binding that fails 1" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:Y}}, false)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == [[X: :iphone, Y: 500]]
    end

    test "test it binds variable and reuses it and return false for the binding that fails 2" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:X}}, false)
      ]

      res = Unifier.unify_list(@bcosts, tests)
      assert res == [[X: :car, Y: 1000], [X: :iphone, Y: 500]]
    end

    test "test it binds variable and reuses it and return false for the binding that fails 3" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:Y}}, false)
      ]

      res = Unifier.unify_list(@bcosts ++ [{:money, {500}}], tests)
      assert res == :cant_unify
    end

    test "test it matches multiple tests with two varible with false test" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :Y}}, true),
        ContextBelief.create({:hate, {:Y}}, false),
      ]

      res = Unifier.unify_list(@b2 ++ [{:hate, {:red}}], tests)
      assert res == :cant_unify
    end

    test "test it matches multiple tests with two varible with false test that does not pass" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :Y}}, true),
        ContextBelief.create({:hate, {:X}}, false),
      ]

      res = Unifier.unify_list(@b2 ++ [{:hate, {:red}}], tests)
      assert res == [[X: 1000, Y: :red]]
    end

    test "test it matches multiple tests with multiple varible with false test that passes" do
      tests = [
        ContextBelief.create({:car, {:X1, :X2}}, true),
        ContextBelief.create({:money, {:Y}}, true),
        ContextBelief.create({:bad_weight, {:X2}}, false),
      ]

      res = Unifier.unify_list(@bwithmoney ++ [{:bad_weight, {1000}}], tests)
      assert res == [[X1: :weight, X2: 20000, Y: 2000], [X1: :color, X2: :red, Y: 2000]]
    end

    test "test it matches multiple tests with multiple varible with 2 false tests that passes" do
      tests = [
        ContextBelief.create({:car, {:X1, :X2}}, true),
        ContextBelief.create({:bad_weight, {:X2}}, false),
        ContextBelief.create({:money, {:Y}}, true),
        ContextBelief.create({:bad_color, {:X2}}, false),
      ]

      res = Unifier.unify_list(@bwithmoney ++ [{:bad_weight, {1000}}, {:bad_color, {:red}}], tests)
      assert res == [[X1: :weight, X2: 20000, Y: 2000]]
    end

    test "test it matches multiple tests with multiple varible with 2 false tests that passes 2" do
      tests = [
        ContextBelief.create({:car, {:X1, :X2}}, true),
        ContextBelief.create({:bad_weight, {:X2}}, false),
        ContextBelief.create({:money, {:Y}}, true),
        ContextBelief.create({:bad_color, {:red}}, false),
      ]

      res = Unifier.unify_list(@bwithmoney ++ [{:bad_weight, {1000}}, {:bad_color, {:red}}], tests)
      assert res == :cant_unify
    end

  end

  describe "variable binding" do

    test "it binds variables to tests" do
      res = Unifier.bind_variables({:money, {:Y}}, [X: :one, Y: 123])
      assert res == {:money, {123}}
    end

    test "it binds to multiple bindings" do
      res = Unifier.multiple_bind_variables({:money, {:Y}}, [[X: :one, Y: 123], [X: :two, Y: 323]])
      assert res == [{[X: :one, Y: 123], {:money, {123}}}, {[X: :two, Y: 323], {:money, {323}}}]
    end

  end

  describe "unify muliple test with function" do

    test "test it unifies when the function passes" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :red}}, true),
      ]

      res = Unifier.unify_list(@b2, tests, fn x -> x > 100 end)
      assert res == [[X: 1000]]
    end

    test "test it unifies when the function passes and other does not" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :blue}}, true),
      ]

      res = Unifier.unify_list(@b2, tests, fn x -> x > 100 end)
      assert res == :cant_unify
    end

    test "test it unifies when the function passes with multiple results" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:money, {:Y}}, true),
        ContextBelief.create({:color, {:X, :Z}}, true),
      ]

      res = Unifier.unify_list(@bcosts, tests, fn x, _, z ->
        x == :car && z == :red
      end)
      assert res == [[X: :car, Y: 1000, Z: :red]]
    end

    test "test it unifies when the function passes with multiple results 2" do
      tests = [
        ContextBelief.create({:cost, {:X, :Y}}, true),
        ContextBelief.create({:color, {:X, :Z}}, true),
      ]

      res = Unifier.unify_list(@bcosts, tests, fn x, _, z ->
        x == :iphone && z == :black
      end)
      assert res == [[X: :iphone, Y: 500, Z: :black]]
    end

    test "test it does not unifi when the function fails" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :red}}, true),
      ]

      res = Unifier.unify_list(@b2, tests, fn x-> x > 10000 end)
      assert res == :cant_unify
    end

    test "test it does not unifie when the function does not find arguments" do
      tests = [
        ContextBelief.create({:car, {:cost, :X}}, true),
        ContextBelief.create({:car, {:color, :red}}, true),
      ]

      res = Unifier.unify_list(@b2, tests, fn x->
        x > 10000
      end)
      assert res == :cant_unify
    end

  end

  describe "binding merging" do

    test "it binds one new to one old" do
      x = Unifier.add_binding_to_bindings([[Y: 2000]], [[X: 1000]])
      assert x == [[X: 1000, Y: 2000]]
    end

    test "it adds empty new to old" do
      x = Unifier.add_binding_to_bindings([[]], [[X: 1000]])
      assert x == [[X: 1000]]
    end

    test "it adds empty old to new" do
      x = Unifier.add_binding_to_bindings([[X: 1000]], [[]])
      assert x == [[X: 1000]]
    end

    test "it adds multiple new to multiple old" do
      x = Unifier.add_binding_to_bindings([[Y: 2000, W: :"Value"]], [[X: 1000, Z: 333]])
      assert x == [[X: 1000, Z: 333, Y: 2000, W: :Value]]
    end

  end

  describe "Unify beliefs with multiple bindings" do

    test "it unifies a test with constants with empty bindings" do
      test = ContextBelief.create({:car, {:cost, 1000}}, true)
      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, [[]])
      assert res == [[]]
    end

    test "it unifies a test with constants with multiple bindings" do
      test = ContextBelief.create({:car, {:cost, 1000}}, true)
      bindings = [[X: :car, Y: 1000], [X: :mobile, Y: 500]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == [[X: :car, Y: 1000], [X: :mobile, Y: 500]]
    end

    test "it unifies a test with different variables with multiple bindings" do
      test = ContextBelief.create({:car, {:cost, :Z}}, true)

      bindings = [[X: :car, Y: 1000], [X: :mobile, Y: 500]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == [[X: :car, Y: 1000, Z: 1000], [X: :mobile, Y: 500, Z: 1000]]
    end

    test "it unifies a test with same variables with multiple bindings" do
      test = ContextBelief.create({:car, {:cost, :Y}}, true)
      bindings = [[X: :car, Y: 1000], [X: :mobile, Y: 500]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == [[X: :car, Y: 1000]]
    end

    test "it returns cant unify if it cant unify" do
      test = ContextBelief.create({:car, {:cost1, :Y}}, true)
      bindings = [[X: :car, Y: 1000], [X: :mobile, Y: 500]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == :cant_unify
    end

  end

  def remove_original(res) do
    Enum.map(res,
             fn {res, _, bind} -> {res, bind}
             el -> el
    end)
  end

end
