defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """

  import Guards

  def part_one(file_name \\ "test-data") do
    fetch_data("./lib/#{file_name}.txt")
    |> Enum.filter(&is_safe?/1)
    |> Enum.count()
  end

  defp fetch_data(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn ls -> Enum.map(ls, &String.to_integer/1) end)
  end

  def is_safe?(ls)

  def is_safe?([]), do: false    # malformed
  def is_safe?([_]), do: false   # malformed

  def is_safe?([first | [second | _]]) when not is_safe_interval(first, second), do: false

  def is_safe?([first | [second | _] = rest]) do
    up_or_down = if second > first, do: :up, else: :down

    result = 
      rest
      |> Enum.reduce_while({first, up_or_down}, fn
        el, {prev, _} when not is_safe_interval(prev, el) -> 
          {:halt, false}

        el, {prev, :up} when is_down_interval(prev, el) ->
          {:halt, false}

        el, {prev, :down} when is_up_interval(prev, el) -> 
          {:halt, false}

        el, {_, up_or_down} -> 
          {:cont, {el, up_or_down}}
      end)

    if result == false, do: false, else: true
  end
end
