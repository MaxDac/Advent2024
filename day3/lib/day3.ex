defmodule Day3 do
  @moduledoc """
  Documentation for `Day3`.
  """

  @mul_regex ~r/mul\(\d+,\d+\)/
  @mul_regex_numbers ~r/mul\((\d+),(\d+)\)/

  def run(file_name \\ "test-data") do
    muls =
      fetch_data("./lib/#{file_name}.txt")
      |> Stream.map(&Regex.scan(@mul_regex, &1))
      |> Stream.flat_map(& &1)
      |> Enum.flat_map(& &1)

    muls
    |> Enum.map(&execute_mul/1)
    |> Enum.sum()
  end

  defp fetch_data(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
  end
  
  defp execute_mul(mul) do
    with {num1, num2} <- extract_numbers_from_mul(mul) do
      num1 * num2
    end
   end

  defp extract_numbers_from_mul(mul) do
    with [_, num1, num2] <- Regex.run(@mul_regex_numbers, mul) do
      {String.to_integer(num1), String.to_integer(num2)}
    end
  end
end
