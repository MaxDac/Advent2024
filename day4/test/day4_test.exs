defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  @matrix """
  MMMS
  MSAM
  AMXS
  MSAM
  """

  # M M M S
  # M S A M
  # A M X S
  # M S A M

  def get_lines(_) do
    lines =
      @matrix
      |> String.split("\n", trim: true)

    %{lines: lines}
  end

  describe "get_subdiagonal_line" do
    setup [:get_lines]    

    test "main diagonal", %{lines: lines} do
      assert "MSXM" == Day4.get_diagonal_line(lines, Enum.count(lines)) 
    end

    test "anti diagonal", %{lines: lines} do
      assert "SAMM" == Day4.get_antidiagonal_line(lines, Enum.count(lines)) 
    end

    test "sub diagonal bottom left", %{lines: lines} do
      assert "MMA" == Day4.get_subdiagonal_line(lines, 1, 0, :left_right, Enum.count(lines))
      assert "AS" == Day4.get_subdiagonal_line(lines, 2, 0, :left_right, Enum.count(lines))
    end

    test "sub diagonal top right", %{lines: lines} do
      assert "MAS" == Day4.get_subdiagonal_line(lines, 0, 1, :left_right, Enum.count(lines))
      assert "MM" == Day4.get_subdiagonal_line(lines, 0, 2, :left_right, Enum.count(lines))
    end

    test "sub diagonal top left", %{lines: lines} do
      assert "ASM" == Day4.get_subdiagonal_line(lines, 2, 0, :right_left, Enum.count(lines))
      assert "MM" == Day4.get_subdiagonal_line(lines, 1, 0, :right_left, Enum.count(lines))
    end

    test "sub diagonal bottom right", %{lines: lines} do
      assert "SXM" == Day4.get_subdiagonal_line(lines, 3, 1, :right_left, Enum.count(lines))
      assert "AS" == Day4.get_subdiagonal_line(lines, 3, 2, :right_left, Enum.count(lines))
    end
  end

  describe "get_subdiagonal_lines" do
    setup [:get_lines]    

    test "bottom_left works", %{lines: lines} do
      diagonals = Day4.get_subdiagonal_lines(lines, :bottom_left, 4, 2)

      assert 2 == Enum.count(diagonals)
      assert Enum.any?(diagonals, & &1 == "MMA")
      assert Enum.any?(diagonals, & &1 == "AS")

      assert 1 == Enum.count(Day4.get_subdiagonal_lines(lines, :bottom_left, 4, 3))
    end

    test "top_right works", %{lines: lines} do
      diagonals = Day4.get_subdiagonal_lines(lines, :top_right, 4, 2)

      assert 2 == Enum.count(diagonals)
      assert Enum.any?(diagonals, & &1 == "MAS")
      assert Enum.any?(diagonals, & &1 == "MM")

      assert 1 == Enum.count(Day4.get_subdiagonal_lines(lines, :top_right, 4, 3))
    end

    test "top_left works", %{lines: lines} do
      diagonals = Day4.get_subdiagonal_lines(lines, :top_left, 4, 2)

      assert 2 == Enum.count(diagonals)
      assert Enum.any?(diagonals, & &1 == "MM")
      assert Enum.any?(diagonals, & &1 == "ASM")

      assert 1 == Enum.count(Day4.get_subdiagonal_lines(lines, :top_left, 4, 3))
    end

    test "bottom_right works", %{lines: lines} do
      diagonals = Day4.get_subdiagonal_lines(lines, :bottom_right, 4, 2)

      assert 2 == Enum.count(diagonals)
      assert Enum.any?(diagonals, & &1 == "SXM")
      assert Enum.any?(diagonals, & &1 == "AS")

      assert 1 == Enum.count(Day4.get_subdiagonal_lines(lines, :bottom_right, 4, 3))
    end
  end

  describe "get_diagonal_lines" do
    setup [:get_lines]    

    test "gets all the diagonal lines", %{lines: lines} do
      assert 10 == Enum.count(Day4.get_diagonal_lines(lines, "XM"))
      assert 6 == Enum.count(Day4.get_diagonal_lines(lines, "XMA"))
      assert 2 == Enum.count(Day4.get_diagonal_lines(lines, "XMAS"))
    end
  end
end
