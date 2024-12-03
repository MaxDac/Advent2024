defmodule Day3 do
  @moduledoc """
  Documentation for `Day3`.
  """

  @mul_regex ~r/mul\(\d+,\d+\)|do\(\)|don't\(\)/
  @mul_regex_numbers ~r/mul\((\d+),(\d+)\)|do\(\)|don't\(\)/

  @block_operation "don't()"
  @restart_operation "do()"

  def run(file_name \\ "test-data") do
    muls =
      fetch_data("./lib/#{file_name}.txt")
      |> Stream.map(&Regex.scan(@mul_regex, &1))
      |> Stream.flat_map(& &1)
      |> Enum.flat_map(& &1)

    {_, sum} =
      muls
      |> Enum.map(&execute_operation/1)
      |> Enum.reduce({:restart, 0}, fn 
        {:mul, result}, {:restart, acc} -> {:restart, acc + result}
        {:mul, _}, {:block, acc} -> {:block, acc}
        :block, {_, acc} -> {:block, acc}
        :restart, {_, acc} -> {:restart, acc}
      end)

    sum
  end

  defp fetch_data(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
  end
  
  defp execute_operation(mul) do
    case Regex.run(@mul_regex_numbers, mul) do
      [_, num1, num2] -> {:mul, String.to_integer(num1) * String.to_integer(num2)}
      [@block_operation] -> :block
      [@restart_operation] -> :restart
    end
  end
end
