defmodule Day5 do
  @moduledoc """
  Documentation for `Day5`.
  """

  @rule_divider "|"
  @updates_divider ","

  def part1(file_name \\ "test-data") do
    {rules, updates} = read_file(file_name)
    {pre_rules, post_rules} = map_rules(rules)

    updates
    |> map_updates()
    # |> Enum.filter(&check_update(&1, pre_rules))
    |> Enum.filter(fn x -> not check_update(x, pre_rules) end)
    |> Enum.map(&reorder_elements(&1, pre_rules, post_rules))
    |> Enum.map(&get_middle_element/1)
    |> Enum.sum()
  end

  defp read_file(file_name) do
    File.stream!("./lib/#{file_name}.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.split_while(& &1 != "")
  end

  def map_rules(rules) do
    {pre_rule, post_rule} =
      rules
      |> Enum.map(&String.split(&1, @rule_divider))
      |> Enum.flat_map(fn [pre, post] -> [{pre, :pre, post}, {post, :post, pre}] end)
      |> Enum.split_with(&elem(&1, 1) == :pre)

    {
      create_rule_map(pre_rule),
      create_rule_map(post_rule)
    }
  end

  defp create_rule_map(rules) do
    Enum.reduce(rules, %{}, fn {key, _, rule_item}, map -> 
      Map.update(map, key, [rule_item], &[rule_item | &1])
    end)
  end

  def map_updates(updates) do
    updates
    |> Enum.filter(& &1 != "")
    |> Enum.map(&String.split(&1, @updates_divider))
  end

  def check_update(update, pre_rules) do
    update_count = Enum.count(update)

    indexes = 
      for pre <- 0..update_count,post <- 0..update_count, pre < post, do: 
        {Enum.at(update, pre), Enum.at(update, post)}

    Enum.reduce_while(indexes, true, fn {pre, post}, _ -> 
      if Map.has_key?(pre_rules, post) do
        pres = Map.get(pre_rules, post)

        if Enum.any?(pres, & &1 == pre) do
          {:halt, false} 
        else
          {:cont, true}
        end 
      else
        {:cont, true}
      end
    end)
  end

  @doc """
  Reordering the elements leveraging the built in sort algorithm from Elixir,
  determining which element goes first based on the given rules.
  No need to change the rules data structure, the algorithm responds in
  a good enough time (~20ms) already.
  """
  def reorder_elements(update, pre_rules, post_rules) do
    update
    |> Enum.sort(fn a, b ->    
      if Map.has_key?(pre_rules, a) do
        pre_rules
        |> Map.get(a)
        |> Enum.any?(& &1 == b)
      else
        if Map.has_key?(post_rules, b) do
          post_rules
          |> Map.get(b)
          |> Enum.any?(& &1 == a)
        else
          # Might be equal?
          true
        end
      end
    end)
  end

  def get_middle_element(update) do
    update
    |> Enum.at(div(Enum.count(update), 2))
    |> String.to_integer()
  end
end
