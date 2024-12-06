defmodule Day6 do
  @moduledoc """
  Documentation for `Day6`.
  """

  @type direction() :: :up | :down | :left | :right

  @block_char "#"
  @cursor_regex ~r/\^|v|>|</

  def part1(file_name \\ "test-data") do
    matrix =
      read_file(file_name)
      |> map_matrix()

    matrix_size = Enum.count(matrix)
    {row, col} = cursor_initial_position = find_cursor_position(matrix)

    guard_direction =
      matrix
      |> get_matrix_element(row, col)
      |> get_guard_direction()

    {_, visited} = simulate_guard_run(matrix, matrix_size, cursor_initial_position, guard_direction)

    initial_visited = Map.put(%{}, cursor_initial_position, guard_direction)

    :timer.tc(fn ->
      visited
      |> Map.keys()

      # Streaming new matrix
      |> Stream.map(fn pos -> {pos, put_obstacle(matrix, pos)} end)

      # Map sequentially with already streamed new matrix
      # |> Enum.map(fn {pos, new_matrix} ->
      #   result = simulate_guard_loop(new_matrix, matrix_size, cursor_initial_position, guard_direction, initial_visited)
      #   {pos, result}
      # end)

      # Map in parallel with already streamed new matrix
      |> Enum.map(fn {pos, new_matrix} ->
        Task.async(fn -> 
          result = simulate_guard_loop(new_matrix, matrix_size, cursor_initial_position, guard_direction, initial_visited)
          {pos, result}
        end)
      end)
      |> Enum.map(&Task.await/1)

      # Mapping matrixes in parallel
      # |> Stream.map(fn pos ->
      #   Task.async(fn -> 
      #     new_matrix = put_obstacle(matrix, pos)
      #     result = simulate_guard_loop(new_matrix, matrix_size, cursor_initial_position, guard_direction, initial_visited)
      #     {pos, result}
      #   end)
      # end)
      # |> Stream.map(&Task.await/1)

      |> Enum.filter(fn {_, result} -> result == :loop end)
      |> Enum.count()
    end)
  end

  defp read_file(file_name) do
    File.stream!("./lib/#{file_name}.txt")
    |> Stream.map(&String.trim/1)
  end

  def map_matrix(file_content) do
    file_content    
    |> Stream.filter(& &1 != "")
    |> Stream.with_index()
    |> Map.new(fn {line, index} -> {index, line} end)
  end

  def find_cursor_position(matrix) do
    matrix
    |> Enum.reduce_while(nil, fn {row, value}, _ ->
      if Regex.match?(@cursor_regex, value) do
        [match] = Regex.run(@cursor_regex, value)
        col = find_first_index(value, match)
        {:halt, {row, col}}
      else
        {:cont, nil}
      end
    end)
  end

  def put_obstacle(matrix, {row, col} = _obstacle_position) do
    Map.update(matrix, row, "", &replace_char(&1, col, @block_char))
  end

  def simulate_guard_loop(matrix, n, guard_position, direction, visited) do
    case find_next_obstacle(matrix, guard_position, direction, n) do
      {:out, _last_position} ->
        #Out of the field, no loop
        :out
      ^guard_position ->
        simulate_guard_loop(matrix, n, guard_position, change_guard_direction(direction), visited)
      last_position -> 
        if Map.has_key?(visited, last_position) do
          :loop
        else
          simulate_guard_loop(
            matrix, 
            n, 
            last_position, 
            change_guard_direction(direction), 
            Map.put(visited, last_position, direction))
        end
    end
  end

  def simulate_guard_run(matrix, n, guard_position, direction, visited \\ %{}) do
    case find_next_obstacle(matrix, guard_position, direction, n) do
      {:out, last_position} -> 
        visited = 
          visited
          |> compute_visited_positions(guard_position, last_position, direction)
          # |> Enum.count()

        {last_position, visited}
      last_position -> 
        simulate_guard_run(
          matrix, 
          n, 
          last_position, 
          change_guard_direction(direction), 
          compute_visited_positions(visited, guard_position, last_position, direction))
    end
  end

  def compute_visited_positions(visited, starting_point, ending_point, direction)

  def compute_visited_positions(visited, {row, s_col}, {row, e_col}, direction) do
    Enum.reduce(s_col..e_col, visited, fn col, acc ->
      Map.put_new(acc, {row, col}, direction)
    end)
  end

  def compute_visited_positions(visited, {s_row, col}, {e_row, col}, direction) do
    Enum.reduce(s_row..e_row, visited, fn row, acc ->
      Map.put_new(acc, {row, col}, direction)
    end)
  end

  @spec find_next_obstacle(
    matrix :: map(), 
    current_position :: {non_neg_integer(), non_neg_integer()},
    direction :: direction(),
    n :: non_neg_integer()) ::
    {non_neg_integer(), non_neg_integer()} | {:out, {non_neg_integer(), non_neg_integer()}}
  def find_next_obstacle(matrix, current_position, direction, n)

  def find_next_obstacle(matrix, {row, col}, :up, _) do
    block_rows =
      (for r <- (row - 1)..0 do
        {r, get_matrix_element(matrix, r, col) == @block_char}
      end)
      |> first_element(fn {_, found} -> found end)
      |> Enum.map(&elem(&1, 0))

    case block_rows do
      [block_row] -> {block_row + 1, col}
      _ -> {:out, {0, col}}
    end
  end

  def find_next_obstacle(matrix, {row, col}, :down, n) do
    block_rows =
      (for r <- row..(n - 1) do
        {r, get_matrix_element(matrix, r, col) == @block_char}
      end)
      |> first_element(fn {_, found} -> found end)
      |> Enum.map(&elem(&1, 0))

    case block_rows do
      [block_row] -> {block_row - 1, col}
      _ -> {:out, {n - 1, col}}
    end
    
  end

  def find_next_obstacle(matrix, {row, col}, :left, _) do
    reversed_block_col = 
      matrix
      |> Map.get(row)
      |> String.slice(0..(col - 1))
      # Reversing, as we're going in the inverse direction of the string
      |> String.reverse()
      |> find_first_index(@block_char)

    if is_nil(reversed_block_col), 
      do: {:out, {row, 0}}, 
      # col - block_col as block_col in this case refers to the distance to the next block in a reversed string
      else: {row, col - reversed_block_col}
  end

  def find_next_obstacle(matrix, {row, col}, :right, n) do
    block_col = 
      matrix
      |> Map.get(row)
      |> String.slice((col + 1)..(n - 1))
      |> find_first_index(@block_char)

    if is_nil(block_col), 
      do: {:out, {row, n - 1}}, 
      else: {row, block_col + col}
  end

  def get_guard_direction(pointer)
  def get_guard_direction("^"), do: :up
  def get_guard_direction(">"), do: :right
  def get_guard_direction("<"), do: :left
  def get_guard_direction("v"), do: :down

  @doc """
  The guard will always turn right.
  """
  def change_guard_direction(current_pointer)
  def change_guard_direction(:up), do: :right
  def change_guard_direction(:right), do: :down
  def change_guard_direction(:down), do: :left
  def change_guard_direction(:left), do: :up

  def get_matrix_element(matrix, row, col) do
    matrix
    |> Map.get(row)
    |> String.at(col)
  end

  def find_first_index(string, char) do
    string
    |> String.graphemes()
    |> Enum.find_index(& &1 == char)
  end

  def first_element(enum, f)
  def first_element([], _), do: []
  def first_element([first | rest], f) do
    if f.(first), do: [first], else: first_element(rest, f)
  end

  def replace_char(string, index, replacement) do
    prefix = String.slice(string, 0, index)
    suffix = String.slice(string, index + 1, String.length(string) - index - 1)
    prefix <> replacement <> suffix
  end
end
