defmodule Part2 do
  @moduledoc """
  Part 2 helper methods.
  """

  @x_center_char "A"
  @x_border_1 "M"
  @x_border_2 "S"

  def count_mases(lines) do
    indexed_map = lines_as_indexed_map(lines)

    indexed_map
    |> find_a_indexes()
    |> Enum.count(fn {row, col} -> check_coordinate(indexed_map, row, col) end)
  end

  def lines_as_indexed_map(lines) do
    lines    
    |> Stream.with_index()
    |> Map.new(fn {item, index} -> {index, item} end)
  end

  def find_a_indexes(indexed_map) do
    n = Enum.count(indexed_map)

    for {line_index, line} <- indexed_map, 
        index <- 0..String.length(line), 
        is_suitable_x_center(line, index, line_index, n)
         do
      {line_index, index}
    end
  end

  def is_suitable_x_center(line, index, line_index, n)

  # First or last line, impossible X 
  def is_suitable_x_center(_, _, line_index, n) when line_index == 0 or line_index == (n - 1), do: false

  # First or last column, impossibile X
  def is_suitable_x_center(_, index, _, n) when index == 0 or index == (n - 1), do: false

  def is_suitable_x_center(line, index, _, _), do: String.at(line, index) == @x_center_char

  def check_coordinate(indexed_map, row, col) do
    {nw, ne, sw, se} = {
      indexed_map |> Map.get(row - 1) |> String.at(col - 1),
      indexed_map |> Map.get(row - 1) |> String.at(col + 1),
      indexed_map |> Map.get(row + 1) |> String.at(col - 1),
      indexed_map |> Map.get(row + 1) |> String.at(col + 1),
    }

    nw_se = (nw == @x_border_1 && se == @x_border_2) or (nw == @x_border_2 && se == @x_border_1)
    ne_sw = (ne == @x_border_1 && sw == @x_border_2) or (ne == @x_border_2 && sw == @x_border_1)

    nw_se && ne_sw
  end
end