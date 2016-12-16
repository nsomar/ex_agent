defmodule ParsingUtilsTest do
  use ExUnit.Case

  test "it can parse 1 belief base from macro" do
    bb = [do: {:man, [line: 10], [:omar]}]

    assert ParsingUtils.parse_beliefs(bb) == {:man, {:omar}}
  end

  test "it can parse multiple beliefs base from macro" do
    bb = [do: {:__block__, [],
  [{:cost, [line: 5], [:car, 10000]}, {:cost, [line: 6], [:iphone, 500]},
   {:color, [line: 7], [:car, :red]}, {:color, [line: 8], [:iphone, :black]},
   {:is, [line: 9], [:man, :omar]}]}]

    assert ParsingUtils.parse_beliefs(bb) ==
      [
        {:cost, {:car, 10000}},
        {:cost, {:iphone, 500}},
        {:color, {:car, :red}},
        {:color, {:iphone, :black}},
        {:is, {:man, :omar}},
      ]
  end
end
