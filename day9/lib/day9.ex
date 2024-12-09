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
      # |> print_disk_map()
    end)
  end

  defp read_file(file_name) do
    [line] = 
      File.stream!("./lib/#{file_name}.txt")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(& &1 != "")

    line
  end

  @spec map_disk_space(line :: String.t()) :: {list(DiskSpace.t()), list(DiskSpace.t())}
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

    {Enum.reverse(list), filter_empty_values(list)}
  end

  def filter_empty_values(disk_map) do
    Enum.filter(disk_map, fn %DiskSpace{is_empty: is_empty} -> not is_empty end)
  end

  def optimise_user_disk(disk_map, reversed_disk_map)

  def optimise_user_disk(disk_map, []), do: disk_map

  def optimise_user_disk(disk_map, [%DiskSpace{size: size, index: index} = item | rest]) do
    case split_map_in_empty_space(disk_map, size, index) do
      {nil, _} ->
        optimise_user_disk(disk_map, rest)

      {%DiskSpace{size: ^size}, pre, post} ->
        new_list = Enum.concat(pre, [item | remove_moved_item(post, index)])
        optimise_user_disk(new_list, rest)

      {%DiskSpace{size: empty_size} = empty_item, pre, post} ->
        new_empty_item = %{empty_item | size: empty_size - size}
        new_list = Enum.concat(pre, [item | [new_empty_item | remove_moved_item(post, index)]])
        optimise_user_disk(new_list, rest)
    end
  end

  def split_map_in_empty_space(disk_map, required_size, moving_index) do
    case Enum.split_while(disk_map, fn
      %DiskSpace{index: ^moving_index} -> false
      %DiskSpace{is_empty: false} -> true
      %DiskSpace{size: size} when size < required_size -> true
      _ -> false
    end) do
      {_, [%DiskSpace{index: ^moving_index} | _]} -> 
        {nil, disk_map}

      {pre, [selected_spot | post]} -> 
        {selected_spot, pre, post}

      _ -> 
        {nil, disk_map}
    end
  end

  def remove_moved_item(disk_map, item_index) do
    Enum.map(disk_map, fn 
      %DiskSpace{index: ^item_index, size: size} -> %DiskSpace{is_empty: true, size: size}
      item -> item
     end)
  end

  def print_disk_map(disk_map) do
    disk_map
    |> Enum.map(fn 
      %DiskSpace{index: index, size: size} when not is_nil(index) -> String.duplicate(Integer.to_string(index), size)
      %DiskSpace{size: size} -> String.duplicate(".", size)
    end)
    |> Enum.join()
  end

  def compute_checksum(disk_map) do
    disk_map
    |> Enum.flat_map(fn 
      %DiskSpace{index: index, size: size} when not is_nil(index) ->
        List.duplicate(index, size)

      %DiskSpace{size: size} ->
        List.duplicate(0, size)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {chunk_index, index} -> chunk_index * index end)
    |> Enum.sum()
  end
end
