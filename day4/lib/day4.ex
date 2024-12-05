defmodule Day4 do
  @moduledoc """
  Documentation for `Day4`.
  """

  @word_to_search "XMAS"

  def part1(file_name \\ "test-data") do
    lines = read_file(file_name)

    horizontal = Part1.get_horizontal_lines(lines)
    vertical = Part1.get_vertical_lines(lines)
    diagonal = Part1.get_diagonal_lines(lines, @word_to_search)

    horizontal
    |> Enum.concat(vertical)
    |> Enum.concat(diagonal)
    |> Part1.count_matches()
  end

  def part2(file_name \\ "test-data") do
    lines = read_file(file_name)
    Part2.count_mases(lines)
  end

  defp read_file(file_name) do
    File.stream!("./lib/#{file_name}.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.map(& &1)
  end
end
