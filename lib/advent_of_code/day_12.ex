defmodule AdventOfCode.Day12 do

  defp get_parsed_input() do

    input = AdventOfCode.Input.get!(12, 2023) 

#     input = "???.### 1,1,3
# .??..??...?##. 1,1,3
# ?#?#?#?#?#?#?#? 1,3,1,6
# ????.#...#... 4,1,1
# ????.######..#####. 1,6,5
# ?###???????? 3,2,1"

    # input = "????.#...#... 4,1,1"

    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [springs, counts] = String.split(line, " ")

      %{springs: springs, counts: String.split(counts, ",") |> Enum.map(fn s -> String.to_integer(s) end)}
    end)

  end

  defp get_counts(springs_string) do

    springs_string
    |> String.replace("#", "1")
    |> String.split(".", trim: true)
    |> Enum.map(fn s -> String.length(s) end)
    
  end

  defp get_valid_permutations(springs, counts) do

    unknown_count = springs |> String.graphemes |> Enum.count(& &1 == "?")

    unknown_positions = springs |> String.graphemes |> Enum.with_index() |> Enum.filter(fn {s, _} -> s == "?" end) |> Enum.map(fn {_, i} -> i end)

    total_springs = Enum.reduce(counts, 0, fn count, acc -> acc + count end)

    known_spring_count = springs |> String.graphemes |> Enum.count(& &1 == "#")

    springs_needed = total_springs - known_spring_count

    possible_permutations = Helpers.Permutations.shuffle([".", "#"], unknown_count)
    |> Enum.filter(fn permutation -> 
      Enum.count(permutation, fn s -> s == "#" end) == springs_needed
    end)

    applied_permutations = possible_permutations 
    |> Enum.map(fn permutation -> 
      Enum.with_index(permutation) |> 
      Enum.reduce(springs, fn {s, i}, acc -> 
        acc |> String.graphemes() |> put_in([Access.at(Enum.at(unknown_positions, i))], s) |> Enum.join()
      end)
    end)

    valid_permutations = applied_permutations |> Enum.filter(fn permutation -> 
      get_counts(permutation) == counts
    end)

  end

  def part1(_args) do
    
    input = get_parsed_input()


    Enum.map(input, fn %{springs: springs, counts: counts} -> 
      get_valid_permutations(springs, counts)
      |> length()
      |> IO.inspect(label: "valid_permutations")
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)

  end

  defp transform_input_for_p2(input) do
    Enum.map(input, fn %{springs: springs, counts: counts} -> 
      %{
        springs: List.duplicate(springs, 5)
        |> Enum.join("?"),
        counts: Enum.join(counts, ",")
        |> List.duplicate(5)
        |> Enum.join(",")
        |> String.split(",", trim: true)
        |> Enum.map(fn s -> String.to_integer(s) end)
      }
    end)
  end

  # https://www.youtube.com/watch?v=g3Ms5e7Jdqo
  # watched this video I saw recommended on reddit to understand a solution
  # this impl is mostly the same as the python one in the video, though I added Michael's memoization to speed it up
  def count("", nums) do
    # ran out of springs
    if nums == [], do: 1, else: 0
  end

  def count(springs, []) do
    # ran out of counts
    if String.contains?(springs, "#"), do: 0, else: 1
  end

  def count(springs, counts) do

    [current_count | remaining_counts] = counts

    working_or_unknown = 
      if String.at(springs, 0) in [".", "?"] do
        memoized({String.slice(springs, 1..-1), [current_count | remaining_counts]}, fn ->
          count(String.slice(springs, 1..-1), [current_count | remaining_counts])
        end)
      else
        0
      end

    broken_or_unknown = 
      if String.at(springs, 0) in ["#", "?"] do
        if current_count <= String.length(springs) and 
           not String.contains?(String.slice(springs, 0..current_count - 1), ".") and
           (current_count == String.length(springs) or String.at(springs, current_count) != "#") do
          memoized({String.slice(springs, current_count + 1..-1), remaining_counts}, fn ->
            count(String.slice(springs, current_count + 1..-1), remaining_counts)
          end)
        else
          0
        end
      else
        0
      end

    working_or_unknown + broken_or_unknown
  end

  def part2(_args) do

    input = get_parsed_input()

    input = transform_input_for_p2(input)


    Enum.with_index(input)
    |> Enum.map(fn {row, i} -> 
      count(row[:springs], row[:counts])
      |> IO.inspect(label: "row #{i}")
    end)
    |> Enum.sum()

  end

  # https://github.com/michaelst/aoc/blob/main/lib/advent_of_code/day_12.ex
  defp memoized(key, fun) do
    with nil <- Process.get(key) do
      fun.() |> tap(&Process.put(key, &1))
    end
  end

end
