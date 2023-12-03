defmodule AdventOfCode.Day03 do
  defp parseInput(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn row -> 
      String.split(row, "", trim: true)
    end)
  end

  defp getPartNumStartsAndLens(input) do
    noNewLines = String.replace(input, "\n", "")

    Regex.scan(~r/\d+/, noNewLines, return: :index)
    |> List.flatten()
  end

  defp getPartNumActuals(input) do
    noNewLines = String.replace(input, "\n", "")

    Regex.scan(~r/\d+/, noNewLines)
    |> List.flatten()
  end

  def part1(_args) do
    input = AdventOfCode.Input.get!(3, 2023)
#     input = "467..114..
# ...*......
# ..35..633.
# ......#...
# 617*......
# .....+.58.
# ..592.....
# ......755.
# ...$.*....
# .664.598.."

    grid = parseInput(input)

    gridLen = length(grid) - 1
    rowLen = List.first(grid) |> length()

    partNumStartsAndLens = getPartNumStartsAndLens(input) 
    partNumActuals = getPartNumActuals(input)

    Enum.map(partNumStartsAndLens, fn partNumStartAndLen -> 
      {start, len} = partNumStartAndLen

      x = rem(start, rowLen)
      y = floor(start/rowLen)

      List.duplicate(:blah, len) 
      |> Enum.with_index()
      |> Enum.map(fn arg -> 
        {_, index} = arg

        localX = x + index

        rDigOrPeriod = ~r/\d|\./

        # IO.puts(Enum.at(grid, y) |> Enum.at(localX))
        
        hasSymbol = if (
          #left
          (localX > 0 && !Regex.match?(rDigOrPeriod, Enum.at(grid, y) |> Enum.at(localX - 1))) ||
          #up
          (y > 0 && !Regex.match?(rDigOrPeriod, Enum.at(grid, y - 1) |> Enum.at(localX))) ||
          #right
          (localX < (rowLen - 1) && !Regex.match?(rDigOrPeriod, Enum.at(grid, y) |> Enum.at(localX + 1))) ||
          #down
          (y < gridLen && !Regex.match?(rDigOrPeriod, Enum.at(grid, y + 1) |> Enum.at(localX))) ||
          #upleft
          (localX > 0 && y > 0 && !Regex.match?(rDigOrPeriod, Enum.at(grid, y - 1) |> Enum.at(localX - 1))) ||
          #upright
          (y > 0 && localX < (rowLen - 1) && !Regex.match?(rDigOrPeriod, Enum.at(grid, y - 1) |> Enum.at(localX + 1))) ||
          #downright
          (y < gridLen && localX < (rowLen - 1) && !Regex.match?(rDigOrPeriod, Enum.at(grid, y + 1) |> Enum.at(localX + 1))) ||
          #downleft
          (y < gridLen && localX > 0 && !Regex.match?(rDigOrPeriod, Enum.at(grid, y + 1) |> Enum.at(localX - 1)))
        )
        do
          true
        else
          false
        end

      end)
      
    end)
    |> Enum.with_index()
    |> Enum.filter(fn resultsPerChar -> 
      {results, index} = resultsPerChar
      Enum.member?(results, true)
    end)
    |> Enum.map(fn resultsPerChar -> 
      {_results, index} = resultsPerChar
      Integer.parse(Enum.at(partNumActuals, index)) |> elem(0)
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)

    

  end

  def part2(_args) do
    input = AdventOfCode.Input.get!(2, 2023)

  end
end
