defmodule AdventOfCode.Day04 do
  defp parseNumGrouping(numGrouping) do
    Regex.replace(~r/Card\s+\d+:\s/, numGrouping, "")
    |> String.split(" ", trim: true) 
    |> Enum.map(fn numStr -> 
      Integer.parse(numStr) |> elem(0)
    end)
    # |> IO.inspect([charlists: :as_lists])
  end

  defp parseInput(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line -> 
      lineParts = String.split(line, " | ", trim: true)

      %{
        "winningNums" => parseNumGrouping(Enum.at(lineParts, 0)),
        "myNums" => parseNumGrouping(Enum.at(lineParts, 1))
      }
    end)
  end

  def part1(_args) do
    input = AdventOfCode.Input.get!(4, 2023)
#     input = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
# Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
# Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
# Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
# Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
# Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"

    parsed = parseInput(input)
    |> Enum.map(fn numSet -> 
      nonIntersection = numSet["myNums"] -- numSet["winningNums"]
      inersections =  numSet["myNums"] -- nonIntersection
    end)
    # |> IO.inspect([charlists: :as_lists])
    |> Enum.filter(fn matches -> 
      length(matches) > 0
    end)
    |> Enum.map(fn matches -> 
      2 ** (length(matches) - 1)
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)


  end

  def part2(_args) do
  end
end
