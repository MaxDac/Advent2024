defmodule Day6Test do
  use ExUnit.Case
  doctest Day6

  @matrix """
  ....#.....
  .........#
  ..........
  ..#.......
  .......#..
  ..........
  .#..^.....
  ........#.
  #.........
  ......#...
  """

  def parse_matrix(_) do
    matrix =
      @matrix
      |> String.split("\n")
      |> Day6.map_matrix()

    %{matrix: matrix}
  end

  describe "find_next_obstacle" do
    setup [:parse_matrix]

    test "up direction correctly finds the obstacle", %{matrix: matrix} do
      assert {1, 4} == Day6.find_next_obstacle(matrix, {6, 4}, :up, 10)
      assert {:out, {0, 1}} == Day6.find_next_obstacle(matrix, {3, 1}, :up, 10)
    end

    test "down direction correctly finds the obstacle", %{matrix: matrix} do
      assert {8, 6} == Day6.find_next_obstacle(matrix, {6, 6}, :down, 10)
      assert {:out, {9, 4}} == Day6.find_next_obstacle(matrix, {6, 4}, :down, 10)
    end

    test "left direction correctly finds the obstacle", %{matrix: matrix} do
      assert {6, 2} == Day6.find_next_obstacle(matrix, {6, 4}, :left, 10)
      assert {:out, {9, 0}} == Day6.find_next_obstacle(matrix, {9, 4}, :left, 10)
    end

    test "right direction correctly finds the obstacle", %{matrix: matrix} do
      assert {7, 7} == Day6.find_next_obstacle(matrix, {7, 4}, :right, 10)
      assert {:out, {8, 9}} == Day6.find_next_obstacle(matrix, {8, 4}, :right, 10)
    end
  end

  describe "find_cursor_position" do
    setup [:parse_matrix]

    test "finds correct cursor position", %{matrix: matrix} do
      assert {6, 4} == Day6.find_cursor_position(matrix)
    end
  end
end
