defmodule Day4 do
  @moduledoc """
  Documentation for `Day4`.
  """

  @word_to_search "XMAS"
  @regex_pattern_match ~r/(?=(XMAS|SAMX))/  # Using positive lookahead to match twice instances like SAMXMAS

  def run(file_name \\ "test-data") do
    lines =
      read_file(file_name)
      |> Enum.map(& &1)

    horizontal = get_horizontal_lines(lines)
    vertical = get_vertical_lines(lines)
    diagonal = get_diagonal_lines(lines)

    horizontal
    |> Enum.concat(vertical)
    |> Enum.concat(diagonal)
    |> count_matches()
  end

  defp read_file(file_name) do
    File.stream!("./lib/#{file_name}.txt")
    |> Stream.map(&String.trim/1)
  end

  def get_horizontal_lines(lines) do
    lines
  end

  def get_vertical_lines(lines) do
    for index <- 0..(Enum.count(lines) - 1) do
      lines
      |> Enum.reduce("", fn line, string ->
        String.at(line, index) <> string
      end)
    end
  end

  def get_diagonal_lines(lines, word_to_search \\ @word_to_search) do
    matrix_size = Enum.count(lines)   # Considering a square metrix
    word_length = String.length(word_to_search)

    # Diagonal line
    diagonal = get_diagonal_line(lines, matrix_size)

    # Antidiagonal line
    antidiagonal = get_antidiagonal_line(lines, matrix_size)

    bottom_left = get_subdiagonal_lines(lines, :bottom_left, matrix_size, word_length)
    top_right = get_subdiagonal_lines(lines, :top_right, matrix_size, word_length)
    top_left = get_subdiagonal_lines(lines, :top_left, matrix_size, word_length)
    bottom_right = get_subdiagonal_lines(lines, :bottom_right, matrix_size, word_length)

    # IO.inspect(bottom_left, label: "bottom_left")
    # IO.inspect(bottom_right, label: "bottom_right")
    # IO.inspect(top_left, label: "top_left")
    # IO.inspect(top_right, label: "top_right")

    [diagonal, antidiagonal]
    |> Enum.concat(bottom_left)
    |> Enum.concat(top_right)
    |> Enum.concat(top_left)
    |> Enum.concat(bottom_right)
  end

  def get_diagonal_line(lines, n) do
    for i <- 0..(n - 1) do
      get_matrix_element(lines, i, i)
    end
    |> Enum.join()
  end

  def get_antidiagonal_line(lines, n) do
    for i <- 0..(n - 1),
        j <- (n - 1)..0,
        i + j == (n - 1) do
      get_matrix_element(lines, i, j)
    end 
    |> Enum.join()
  end

  def get_subdiagonal_lines(lines, quadrant, n, word_length)

  def get_subdiagonal_lines(_, _, n, word_length) when n - word_length < 1, do: []

  def get_subdiagonal_lines(lines, :bottom_left, n, word_length) do
    for row <- 1..(n - word_length), do: get_subdiagonal_line(lines, row, 0, :left_right, n)
  end

  def get_subdiagonal_lines(lines, :top_right, n, word_length) do
    for col <- 1..(n - word_length), do: get_subdiagonal_line(lines, 0, col, :left_right, n)
  end

  def get_subdiagonal_lines(lines, :top_left, n, word_length) do
    for row <- (word_length - 1)..(n - 2), do: get_subdiagonal_line(lines, row, 0, :right_left, n)
  end

  def get_subdiagonal_lines(lines, :bottom_right, n, word_length) do
    for col <- 1..(n - word_length), do: get_subdiagonal_line(lines, n - 1, col, :right_left, n)
  end

  def get_subdiagonal_line(lines, row, col, direction, n)

  def get_subdiagonal_line(lines, row, 0, :left_right, n) do  # bottom-left quadrant
    for i <- row..(n - 1),
        j <- 0..(n - row - 1),
        j == i - row do
      get_matrix_element(lines, i, j)
    end
    |> Enum.join()
  end

  def get_subdiagonal_line(lines, 0, col, :left_right, n) do  # top-right quadrant
    for i <- 0..(n - col - 1),
        j <- col..(n - 1),
        i == j - col do
      get_matrix_element(lines, i, j)
    end
    |> Enum.join()
  end

  def get_subdiagonal_line(lines, row, 0, :right_left, _) do  # top-left quadrant
    for i <- row..0,
        j <- 0..row,
        i + j == row do
      get_matrix_element(lines, i, j)
    end
    |> Enum.join()
  end

  def get_subdiagonal_line(lines, row, col, :right_left, n) do  # bottom-right quadrant
    for i <- row..0,
        j <- col..(n - 1),
        i + j == row + col do
      get_matrix_element(lines, i, j)
    end
    |> Enum.join()
  end

  def get_matrix_element(lines, row, col), do:
    lines
    |> Enum.at(row)
    |> String.at(col)

  def count_matches(lines) do
    lines
    |> Enum.map(&count_match(&1, @regex_pattern_match))
    |> Enum.sum()
  end

  def count_match(string, regex) do
    Regex.scan(regex, string)
    |> Enum.count()
  end
end