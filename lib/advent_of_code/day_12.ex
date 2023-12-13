defmodule AdventOfCode.Day12 do

  defp get_parsed_input() do

    input = AdventOfCode.Input.get!(12, 2023) 

    input = "???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"

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

  # brainstorm
  # can we reduce the problem scope at all, by attempting to replace ? with . in places where they must be .
  # perhaps also replace ? with # in places where they must be #

  # ???.### 1,1,3
  # ?.?.### 1,1,3 - second one must be a .
  #  solved

  # .??..??...?##. 1,1,3
  # .??..??...### 1,1,3 - last one must be a #

  # ?#?#?#?#?#?#?#? 1,3,1,6
  # .#.###.#.###### 1,3,1,6
  #  solved

  def part2(_args) do

    input = get_parsed_input()

    input = transform_input_for_p2(input)
    
    first = Enum.at(input, 0)

    IO.inspect(first)

    # Regex.scan(~r/(?:(?<=^)|(?<=[.?]))(?:[#?]{3})(?:(?=$)|(?=[.?]))/, first[:springs], return: :index)


    # Enum.map(input, fn %{springs: springs, counts: counts} -> 
    #   get_valid_permutations(springs, counts)
    #   |> length()
    #   |> IO.inspect(label: "valid_permutations")
    # end)
    # |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)


  end
end
