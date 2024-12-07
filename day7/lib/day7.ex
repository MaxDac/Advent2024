defmodule Day7 do
  @moduledoc """
  Documentation for `Day7`.
  """

  @result_operand_divider ":"
  @operand_divider " "
  @operations [:sum, :times]

  def part1(file_name \\ "test-data") do
    input = read_file(file_name)

    operations_map =
      input
      |> Enum.map(fn {_, operands} -> Enum.count(operands) end)
      |> Enum.min_max()
      |> generate_operations_permutations()

    :timer.tc(fn ->
      input
      |> Stream.filter(&check_line(&1, operations_map))
      |> Stream.map(fn {result, _} -> result end)
      |> Enum.sum()
    end)
  end

  defp read_file(file_name) do
    File.stream!("./lib/#{file_name}.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(& &1 != "")
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [result, operands] = split_and_trim(line, @result_operand_divider)

    operands = 
      operands
      |> split_and_trim(@operand_divider)
      |> Enum.map(&String.to_integer/1)

    {String.to_integer(result), operands}
  end

  defp split_and_trim(line, pattern) do
    line
    |> String.split(pattern)
    |> Enum.map(&String.trim/1)
  end

  def generate_operations_permutations({min_n, max_n}) do
    Enum.reduce((min_n - 1)..(max_n - 1), %{}, fn index, map ->
      ps = permutations(@operations, index)
      Map.put(map, index, ps)
    end)
  end

  def permutations(_, 0), do: [[]]
  def permutations(operations, n) do
    for head <- operations,
        tail <- permutations(operations, n - 1) do
      [head | tail]
    end
  end

  def check_line({expected_result, operands}, operations_map) do
    results = perform_line_operations(operands, operations_map)

    Enum.reduce_while(results, false, fn r, _ ->
      if expected_result == r,
        do: {:halt, true},
        else: {:cont, false}
    end)
  end

  def perform_line_operations(operands, operations_map) do
    n = Enum.count(operands)
    operations = Map.get(operations_map, n - 1)

    Enum.map(operations, &perform_operation(operands, &1))
  end

  def perform_operation(operands, operations)

  def perform_operation([acc], _), do: acc
    
  def perform_operation([op1 | [op2 | rest]], [:sum | rest_op]), do: 
    perform_operation([op1 + op2 | rest], rest_op)

  def perform_operation([op1 | [op2 | rest]], [:times | rest_op]), do:
    perform_operation([op1 * op2 | rest], rest_op)
end
