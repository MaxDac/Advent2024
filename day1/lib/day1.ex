defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """
  
  @doc """
  Hello world.

  ## Examples

      iex> Day1.hello()
      :world

  """
  def hello do
    {ls1, ls2} = read_input_data()

    [Enum.sort(ls1), Enum.sort(ls2)]
    |> Enum.zip()
    |> Enum.map(fn {first, second} -> abs(first - second) end)
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
end
