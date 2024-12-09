defmodule Day8 do
  @moduledoc """
  Documentation for `Day8`.
  """

  @empty_space_marker "."

  def part1(file_name \\ "test-data") do
    matrix = read_file(file_name)

    rows = Enum.count(matrix)
    cols = matrix |> Enum.at(0) |> String.length()

    matrix
    |> map_antennas()
    |> Enum.flat_map(fn {_, coordinates} -> 
      find_antinodes_coordinates(coordinates, rows, cols) 
    end)
    |> MapSet.new()
    |> Enum.count()
  end

  defp read_file(file_name) do
    File.stream!("./lib/#{file_name}.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(& &1 != "")
  end

  def map_antennas(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index}, map ->
      map_antennas_line(index, line, map)
    end)
  end

  def map_antennas_line(row, line, map) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {value, _} -> value != @empty_space_marker end)
    |> Enum.reduce(map, fn {char, index}, m ->
      Map.update(m, char, [{row, index}], &[{row, index} | &1])
    end)
  end

  def find_antinodes_coordinates(antenna_coordinates, rows, cols, acc \\ [])

  def find_antinodes_coordinates([], _, _, acc), do: acc

  def find_antinodes_coordinates([_], _, _, acc), do: acc

  def find_antinodes_coordinates([coordinate1 | coordinates], rows, cols, acc) do
    antinodes_coordinates =
      coordinates
      |> Enum.flat_map(fn c ->
        find_antennas_antinodes_coordinates(coordinate1, c, rows, cols)
        |> IO.inspect(label: "antinodes for #{inspect c} - #{inspect coordinate1}")
      end)

    find_antinodes_coordinates(coordinates, rows, cols, Enum.concat(antinodes_coordinates, acc))
  end

  def find_antennas_antinodes_coordinates({r1, c1} = coord1, {r2, c2} = coord2, rows, cols) do
    r = r1 - r2
    c = c1 - c2

    [coord1, coord2]
    |> Enum.concat(add_coordinates(coord1, r, c, rows, cols))
    |> Enum.concat(add_coordinates(coord2, r * -1, c * -1, rows, cols))
  end

  def add_coordinates({r, c} = _from_coord, dr, dc, rows, cols, acc \\ []) do
    new_coord = {r + dr, c + dc}

    if is_inside_matrix?(new_coord, rows, cols) do
      add_coordinates(new_coord, dr, dc, rows, cols, [new_coord | acc])
    else
      acc
    end
  end

  def is_inside_matrix?({row, col}, rows, cols) do
    row >= 0 and row < rows and col >= 0 and col < cols
  end
end
