defmodule Day9 do
  @moduledoc """
  Documentation for `Day9`.
  """

  def part1(file_name \\ "test-data") do
    :timer.tc(fn ->
      line = read_file(file_name)

      {disk_map, reversed_disk_map} = map_disk_space(line)

      optimise_user_disk(disk_map, reversed_disk_map)
      |> compute_checksum()
    end)
  end

  defp read_file(file_name) do
    [line] = 
      File.stream!("./lib/#{file_name}.txt")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(& &1 != "")

    line
  end

  @spec map_disk_space(line :: String.t()) :: list(DiskSpace.t())
  def map_disk_space(line) do
    {_, list, _} =
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce({0, [], :filled}, fn 
        0, {index, ls, :empty} ->
          {index, ls, :filled}

        0, {index, ls, :filled} ->
          {index + 1, ls, :empty}

        size, {index, ls, :filled} ->
          ls = [%DiskSpace{
            index: index,
            size: size
          } | ls]

          {index + 1, ls, :empty}

        size, {index, ls, :empty} ->
          ls = [%DiskSpace{
            is_empty: true,
            size: size
          } | ls]

          {index, ls, :filled}
      end)

    {Enum.reverse(list), list}
  end

  def optimise_user_disk(disk_map, reversed_disk_map, acc \\ [])

  def optimise_user_disk(
      [%DiskSpace{index: index} | _],
      [%DiskSpace{index: index} = remaining_item | _],
      acc) when not is_nil(index) do
    [remaining_item | acc]    
    |> Enum.reverse()
  end

  def optimise_user_disk([%DiskSpace{is_empty: false} = item | rest], reversed_disk_map, acc) do
    optimise_user_disk(rest, reversed_disk_map, [item | acc])
  end

  def optimise_user_disk(
      [%DiskSpace{is_empty: true, size: empty_size} = item | rest], 
      [%DiskSpace{is_empty: false, size: filled_size} = filled_item | rev_rest], 
      acc) do
    case filled_size - empty_size do
      0 -> optimise_user_disk(
        rest, 
        rev_rest, 
        [filled_item | acc])

      ds when ds > 0 -> optimise_user_disk(
        rest, 
        [%{filled_item | size: ds} | rev_rest], 
        [%{filled_item | size: empty_size} | acc])

      ds -> optimise_user_disk(
        [%{item | size: ds * -1} | rest], 
        rev_rest,
        [%{filled_item | size: filled_size} | acc])
    end
  end

  def optimise_user_disk(
      disk_map, 
      [_ | reversed_disk_map], 
      acc) do
    optimise_user_disk(disk_map, reversed_disk_map, acc)
  end

  def print_disk_map(disk_map) do
    disk_map
    |> Enum.map(fn 
      %DiskSpace{index: index, size: size} -> String.duplicate(Integer.to_string(index), size)
    end)
    |> Enum.join()
  end

  def compute_checksum(disk_map) do
    disk_map
    |> Enum.flat_map(&List.duplicate(&1.index, &1.size))
    |> Enum.with_index()
    |> Enum.map(fn {chunk_index, index} -> chunk_index * index end)
    |> Enum.sum()
  end
end
