defmodule AdventOfCode.Day09 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(9, 2023) 
    # |> IO.inspect()

#     input = "0 3 6 9 12 15
# 1 3 6 10 15 21
# 10 13 16 21 30 45"

    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(fn num -> Integer.parse(num) |> elem(0) end)
    end)

  end

  defp get_pyramid(numbers) do

    # IO.inspect(numbers)

    last_nums = Enum.at(numbers, -1)
    
    diffs = Enum.with_index(last_nums)
    |> Enum.map(fn {num, index} ->
      if index == 0 do
        -1
      else
        num - Enum.at(last_nums, index - 1)
      end
    end)
    |> Enum.drop(1)
    # |> IO.inspect()

    if (Enum.filter(diffs, fn num -> num != 0 end) |> length() > 0) do
      get_pyramid(numbers ++ [diffs])
    else 
      numbers ++ [diffs]
    end

  end
  
  defp extrapolate_next_number(rows) do

    rev = Enum.reverse(rows)
    
    all = Enum.with_index(rev)
    |> Enum.reduce([], fn {row, index}, acc ->
      if index == 0 do
        [row ++ [0]]
      else
        acc ++ [row ++ [(Enum.at(acc, index - 1) |> Enum.at(-1)) + Enum.at(row, - 1)]]
      end
    end)
    |> Helpers.Utils.inspect()

    Enum.at(all, -1)
    |> Enum.at(-1)

  end

  def part1(_args) do

    input = get_parsed_input()

    Enum.map(input, fn row ->
      get_pyramid([row])
      |> extrapolate_next_number()
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)
    
  end

  defp extrapolate_prev_number(rows) do

    rev = Enum.reverse(rows)
    
    all = Enum.with_index(rev)
    |> Enum.reduce([], fn {row, index}, acc ->
      if index == 0 do
        [[0] ++ row]
      else
        acc ++ [[Enum.at(row, 0) - (Enum.at(acc, index - 1) |> Enum.at(0))] ++ row]
      end
    end)
    |> Helpers.Utils.inspect()

    Enum.at(all, -1)
    |> Enum.at(0)

  end

  def part2(_args) do

    input = get_parsed_input()

    Enum.map(input, fn row ->
      get_pyramid([row])
      |> extrapolate_prev_number()
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)
    
  end
end
