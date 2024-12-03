defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """

  import Guards

  def part_one(file_name \\ "test-data") do
    fetch_data("./lib/#{file_name}.txt")
    |> Enum.filter(fn x -> is_safe?(x) end)
    |> Enum.count()
  end

  defp fetch_data(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn ls -> Enum.map(ls, &String.to_integer/1) end)
  end

  def is_safe?(ls) do
    case is_safe_internal?(ls) do
      {false, index} ->
        # Getting the results using lists without indexes from direct neighbourhood of the given index
        # Not optimal, but still O(n)
        [result1, result2, result3] =
          -1..1
          |> Enum.map(fn d ->
            ls
            |> remove_index(index + d)
            |> is_safe_internal?()
          end)

        case {result1, result2, result3} do
          {true, _, _} -> true
          {_, true, _} -> true
          {_, _, true} -> true
          _ -> false
        end

      _ -> true
    end
  end

  defp is_safe_internal?(ls)

  defp is_safe_internal?([]), do: false    # malformed
  defp is_safe_internal?([_]), do: false   # malformed

  defp is_safe_internal?([first | [second | _]]) when 
    not is_safe_interval(first, second), do: 
      {false, 0}

  defp is_safe_internal?([first | [second | _] = rest]) do
    up_or_down = if second > first, do: :up, else: :down

    result =
      rest
      |> Enum.reduce_while({first, up_or_down, 0}, fn
        el, {prev, _, idx} when not is_safe_interval(prev, el) -> 
          {:halt, {false, idx}}

        el, {prev, :up, idx} when is_down_interval(prev, el) ->
          {:halt, {false, idx}}

        el, {prev, :down, idx} when is_up_interval(prev, el) -> 
          {:halt, {false, idx}}

        el, {_, up_or_down, idx} -> 
          {:cont, {el, up_or_down, idx + 1}}
      end)

    case result do
      {false, _} = r -> r
      _ -> true
    end
  end

  defp remove_index(ls, index) do
    for {item, idx} <- Enum.with_index(ls), idx != index, do: item
  end
end
