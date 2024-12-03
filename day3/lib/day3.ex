defmodule Day3 do
  @moduledoc """
  Documentation for `Day3`.
  """

  @mul_regex ~r/mul\(\d+,\d+\)|do\(\)|don't\(\)/
  @mul_regex_numbers ~r/mul\((\d+),(\d+)\)/

  @block_operation "don't()"
  @restart_operation "do()"

  def run(file_name \\ "test-data") do
    {_, muls} =
      fetch_data("./lib/#{file_name}.txt")
      |> Stream.map(&Regex.scan(@mul_regex, &1))
      |> Stream.flat_map(& &1)
      |> Stream.flat_map(& &1)
      |> Enum.reduce({:continue, []}, fn
        @block_operation, {_, acc} -> {:block, acc}
        @restart_operation, {_, acc} -> {:continue, acc}
        mul, {:continue, acc} -> {:continue, [mul | acc]}
        _, {:block, acc} -> {:block, acc}
      end)

    muls
    |> Enum.map(&execute_operation/1)
    |> Enum.sum()
  end

  defp fetch_data(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
  end
  
  defp execute_operation(mul) do
    case Regex.run(@mul_regex_numbers, mul) do
      [_, num1, num2] -> String.to_integer(num1) * String.to_integer(num2)
    end
  end
end
