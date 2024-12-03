defmodule Day2Test do
  use ExUnit.Case

  import Guards

  describe "guards" do
    test "is_safe_interval/2 returns correct values" do
      assert is_safe_interval(0, 3)
      assert is_safe_interval(1, 3)
      assert is_safe_interval(2, 3)

      assert is_safe_interval(3, 2)
      assert is_safe_interval(3, 1)
      assert is_safe_interval(3, 0)

      refute is_safe_interval(3, 3)

      refute is_safe_interval(0, 4)
      refute is_safe_interval(4, 0)
    end

    test "is_up_interval/2 returns correct values" do
      assert is_up_interval(2, 3)
      refute is_up_interval(3, 3)
      refute is_up_interval(4, 3)
    end

    test "is_down_interval/2 returns correct values" do
      assert is_down_interval(3, 2)
      refute is_down_interval(3, 3)
      refute is_down_interval(3, 4)
    end
  end

  describe "is_safe?/2" do
    test "returns safe interval" do
      ls = [29, 28, 25, 24, 23, 20]
      assert Day2.is_safe?(ls)
    end

    test "returns safe interval with one faulty report" do
      ls = [29, 30, 28, 25, 24, 23, 20]
      assert Day2.is_safe?(ls)
    end

    test "returns not safe interval with one faulty report" do
      ls = [29, 30, 25, 24, 23, 20]
      refute Day2.is_safe?(ls)
    end

    test "returns safe interval with first one faulty report" do
      ls = [34, 29, 28, 25, 24, 23, 20]
      assert Day2.is_safe?(ls)
    end

    test "returns safe interval from test data 1" do
      ls = [8, 6, 4, 4, 1]
      assert Day2.is_safe?(ls)
    end

    test "returns safe interval from test data 2" do
      ls = [1, 3, 2, 4, 5]
      assert Day2.is_safe?(ls)
    end

    test "test from production 1" do
      ls = [44, 47, 50, 51, 53, 54, 53]
      assert Day2.is_safe?(ls)
    end
  end
end
