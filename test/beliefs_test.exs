defmodule BeliefsTest do
  use ExUnit.Case
  @b [
    {:omar, :strong},
    {:omar, :big},
    {:car, :red},
    {:dog, :yellow}
  ]

  @b2 [
    {:car, :cost, :"1000"},
    {:car, :weight, :"20000"},
    {:car, :color, :red},
    {:car, :speed, :"1000"}
  ]

  @bwithmoney [
    {:car, :cost, :"1000"},
    {:car, :weight, :"20000"},
    {:car, :color, :red},
    {:car, :speed, :"1000"},
    {:money, :"2000"},
    {:money, :spending, :"1400"}
  ]

  @bcosts [
    {:car, :cost, :"1000"},
    {:iphone, :cost, :"500"},
    {:iphone, :color, :black},
    {:car, :color, :red},
    {:car, :speed, :"1000"},
    {:money, :"1000"},
  ]

  test "It can unify a beleif" do
    assert Unifier.unify(@b, {:omar, :strong}) == [[], :cant_unify, :cant_unify, :cant_unify]
  end

  test "It returns not_found if not found" do
    assert Unifier.unify(@b, {:omar1, :strong}) == [:cant_unify, :cant_unify, :cant_unify, :cant_unify]
  end

  test "it returns error when wrong params" do
    assert Unifier.unify(@b, :omar) == :cant_unify
    assert Unifier.unify(:aaa, {:omar}) == :cant_unify
  end

  test "it cant unify tuples of different length" do
    assert Unifier.unify({1}, {1, 2}) == :cant_unify
  end

  test "unifies tuples with constats" do
    l = {:omar, :red}
    r = {:omar, :red}
    res = Unifier.unify(l, r)
    assert res  == []
  end

  test "unifies tuples with variables" do
    l = {:omar, :red}
    r = {:omar, :X}
    res = Unifier.unify(l, r)
    assert res  == [X: :red]
  end

  test "unifies tuples with var and consts" do
    l = {:omar, :cost, :"100"}
    r = {:omar, :X, :"100"}
    res  = Unifier.unify(l, r)
    assert res == [X: :cost]
  end

  test "unifies tuples with multiple vars" do
    l = {:omar, :cost, :"100"}
    r = {:omar, :X, :Y}
    res = Unifier.unify(l, r)
    assert res == [X: :cost, Y: :"100"]
  end

  test "unifies tuples with multiple vars and consts" do
    l = {:omar, :cost, :"100", :dollars}
    r = {:omar, :X, :Y, :dollars}
    res = Unifier.unify(l, r)
    assert res== [X: :cost, Y: :"100"]
  end

  test "fails to unify tuples with multiple vars and consts if last element does not match" do
    l = {:omar, :cost, :"100", :dollars, :a}
    r = {:omar, :X, :Y, :dollars, :b}
    res = Unifier.unify(l, r)
    assert res == :cant_unify
  end

  test "returns cant unify for beleifs that cant unify" do
    r = {:omar, :red}

    res = Unifier.unify(@b, r) |> remove_original
    assert res == [:cant_unify, :cant_unify, :cant_unify, :cant_unify]
  end

  test "unifies a tuple in a beleif without vars" do
    r = {:omar, :big}

    res = Unifier.unify(@b, r) |> remove_original
    assert res == [:cant_unify, [], :cant_unify, :cant_unify]
  end

  test "unifies a tuple in a beleif with a var" do
    r = {:omar, :X}

    res = Unifier.unify(@b, r) |> remove_original
    assert res == [[X: :strong], [X: :big], :cant_unify, :cant_unify]
  end

  test "unifies a tuple in a beleif with only vars" do
    r = {:X, :Y}

    res = Unifier.unify(@b, r) |> remove_original
    assert res == [[X: :omar, Y: :strong], [X: :omar, Y: :big], [X: :car, Y: :red], [X: :dog, Y: :yellow]]
  end

  test "unifies a tuple in a beleif with var and constant" do
    r = {:X, :red}

    res = Unifier.unify(@b, r) |> remove_original
    assert res == [:cant_unify, :cant_unify, [X: :car], :cant_unify]
  end

  test "unifies a tuple in a beleif with vars and constants" do
    r = {:car, :X, :"1000"}

    res = Unifier.unify(@b2, r) |> remove_original
    assert res == [[X: :cost], :cant_unify, :cant_unify, [X: :speed]]
  end

  test "unifies a tuple in a beleif with multiple variables" do
    r = {:car, :X, :Y}

    res = Unifier.unify(@b2, r) |> remove_original
    assert res == [[X: :cost, Y: :"1000"], [X: :weight, Y: :"20000"], [X: :color, Y: :red], [X: :speed, Y: :"1000"]]
  end

  test "unifies a tuple in a beleif with ending vars" do
    r = {:car, :cost, :Y}

    res = Unifier.unify(@b2, r) |> remove_original
    assert res == [[Y: :"1000"], :cant_unify, :cant_unify, :cant_unify]
  end

  test "returns the original beleif" do
    r = {:car, :X, :"1000"}

    res = Unifier.unify(@b2, r)
    assert res == [[X: :cost], :cant_unify, :cant_unify, [X: :speed]]
  end

  test "test it cleans out the wrong results" do
    r = {:car, :cost, :Y}
    res = Unifier.unify(@b2, r) |> Unifier.remove_ununified
    assert res == [[Y: :"1000"]]
  end

  test "test it fails to unify if first cant be unified" do
    tests = [{:car, :cost, :"100011"}, {:car, :color, :red}]
    res = Unifier.unify_list(@b2, tests)
    assert res == :cant_unify
  end

  test "test it fails to unify if second cant be unified" do
    tests = [{:car, :cost, :"1000"}, {:car, :color, :red1}]
    res = Unifier.unify_list(@b2, tests)
    assert res == :cant_unify
  end

  test "test it matches multiple tests" do
    tests = [{:car, :cost, :"1000"}, {:car, :color, :red}]
    res = Unifier.unify_list(@b2, tests)
    assert res == [[]]
  end

  test "test it matches multiple tests with one varible" do
    tests = [{:car, :cost, :X}, {:car, :color, :red}]
    res = Unifier.unify_list(@b2, tests)
    assert res == [[X: :"1000"]]
  end

  test "test it matches multiple tests with two varible" do
    tests = [{:car, :cost, :X}, {:car, :color, :Y}]
    res = Unifier.unify_list(@b2, tests)
    assert res == [[X: :"1000", Y: :red]]
  end

  test "test it matches multiple tests with multiple varible" do
    tests = [{:car, :X1, :X2}, {:money, :Y}]
    res = Unifier.unify_list(@bwithmoney, tests)
    assert res == [[X1: :cost, X2: :"1000", Y: :"2000"], [X1: :weight, X2: :"20000", Y: :"2000"], [X1: :color, X2: :red, Y: :"2000"], [X1: :speed, X2: :"1000", Y: :"2000"]]
  end

  test "test it binds variable and reuses it" do
    tests = [{:X, :cost, :Y}, {:money, :Y}]
    res = Unifier.unify_list(@bcosts, tests)
    assert res == [[X: :car, Y: :"1000"]]
  end

  test "it binds variable and reuses it and return cant unify if not possible" do
    tests = [{:X, :cost, :Y}, {:money1, :Y}]
    res = Unifier.unify_list(@bcosts, tests)
    assert res == :cant_unify
  end

  test "it binds difficult combinations" do
    tests = [{:X, :cost, :Y}, {:X, :color, :Z}]
    res = Unifier.unify_list(@bcosts, tests)
    assert res == [[X: :car, Y: :"1000", Z: :red], [X: :iphone, Y: :"500", Z: :black]]
  end

  test "it binds three combinations" do
    tests = [{:X, :cost, :Y}, {:money, :Y}, {:X, :color, :Z}]
    res = Unifier.unify_list(@bcosts, tests)
    assert res == [[X: :car, Y: :"1000", Z: :red]]
  end

  test "it binds three combinations and returns cant_unify if wrong" do
    tests = [{:X, :cost, :Y}, {:money, :Y}, {:X, :color, :blue}]
    res = Unifier.unify_list(@bcosts, tests)
    assert res == :cant_unify
  end

  test "it binds variables to tests" do
    res = Unifier.bind_variables({:money, :Y}, [X: :one, Y: :"123"])
    assert res == {:money, :"123"}
  end

  test "it binds to multiple bindings" do
    res = Unifier.multiple_bind_variables({:money, :Y}, [[X: :one, Y: :"123"], [X: :two, Y: :"323"]])
    assert res == [{[X: :one, Y: :"123"], {:money, :"123"}}, {[X: :two, Y: :"323"], {:money, :"323"}}]
  end

  describe "Unify beliefs with multiple bindings" do

    test "it unifies a test with constants with empty bindings" do
      test = {:car, :cost, :"1000"}
      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, [[]])
      assert res == [[]]
    end

    test "it unifies a test with constants with multiple bindings" do
      test = {:car, :cost, :"1000"}
      bindings = [[X: :car, Y: :"1000"], [X: :mobile, Y: :"500"]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == [[X: :car, Y: :"1000"], [X: :mobile, Y: :"500"]]
    end

    test "it unifies a test with different variables with multiple bindings" do
      test = {:car, :cost, :Z}
      bindings = [[X: :car, Y: :"1000"], [X: :mobile, Y: :"500"]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == [[X: :car, Y: :"1000", Z: :"1000"], [X: :mobile, Y: :"500", Z: :"1000"]]
    end

    test "it unifies a test with same variables with multiple bindings" do
      test = {:car, :cost, :Y}
      bindings = [[X: :car, Y: :"1000"], [X: :mobile, Y: :"500"]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == [[X: :car, Y: :"1000"]]
    end

    test "it returns cant unify if it cant unify" do
      test = {:car, :cost1, :Y}
      bindings = [[X: :car, Y: :"1000"], [X: :mobile, Y: :"500"]]

      res = Unifier.unify_beleifs_with_test_and_bindings(@b2, test, bindings)
      assert res == :cant_unify
    end

  end

  def remove_original(res) do
    res |> Enum.map(
      fn
        {res, _, bind} -> {res, bind}
        el -> el
      end
    )
  end
end
