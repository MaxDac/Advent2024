defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """
  
  def part_one do
    {ls1, ls2} = read_input_data()

    [Enum.sort(ls1), Enum.sort(ls2)]
    |> Enum.zip()
    |> Enum.map(fn {first, second} -> abs(first - second) end)
    |> Enum.sum()
  end

  def part_two do
    {ls1, ls2} = read_input_data()

    map = compute_frequency(ls2)

    ls1
    |> Enum.filter(&Map.has_key?(map, &1)) # Filtering only existing one, the others have null contribution
    |> Enum.map(fn x -> x * Map.get(map, x) end)
    |> Enum.sum()
  end

  defp read_input_data do
    File.stream!("./lib/data.txt")
    |> Stream.map(&String.split(&1, " ", trim: true))
    |> Stream.map(fn [first, second] -> {strip_string_to_integer(first), strip_string_to_integer(second)} end)
    |> Enum.unzip()
  end

  defp strip_string_to_integer(s) do
    s
    |> String.replace("\n", "")
    |> String.to_integer()
  end

  defp compute_frequency(ls, acc \\ Map.new())

  defp compute_frequency([], map), do: map

  defp compute_frequency([first | rest], map) do
    if Map.has_key?(map, first) do
      compute_frequency(rest, Map.update!(map, first, & &1 + 1))
    else
      compute_frequency(rest, Map.put_new(map, first, 1))
    end
  end
end
