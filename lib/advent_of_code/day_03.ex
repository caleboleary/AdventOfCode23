defmodule AdventOfCode.Day03 do
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

    grid = Helpers.CalbeGrid.parse(input, "\n", "")

    gridLen = Helpers.CalbeGrid.get_grid_len(grid)
    rowLen = Helpers.CalbeGrid.get_grid_width(grid)

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

        transformations = [
          %{x: -1, y: 0},
          %{x: 0, y: -1},
          %{x: 1, y: 0},
          %{x: 0, y: 1},
          %{x: -1, y: -1},
          %{x: 1, y: -1},
          %{x: 1, y: 1},
          %{x: -1, y: 1}
        ]

        explored_points = Enum.map(transformations, fn transformation -> 
          !Regex.match?(rDigOrPeriod, Helpers.CalbeGrid.get_by_point_and_transformation(grid, localX, y, {transformation[:x], transformation[:y]}, "."))
        end)
        
        hasSymbol = Enum.member?(explored_points, true)

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

    grid = Helpers.CalbeGrid.parse(input, "\n", "")

    gridLen = length(grid) - 1
    rowLen = List.first(grid) |> length()

    partNumStartsAndLens = getPartNumStartsAndLens(input) 
    partNumActuals = getPartNumActuals(input)

    partsAndGears = Enum.with_index(partNumStartsAndLens)
    |> Enum.map(fn wIndex -> 
      {partNumStartAndLen, partIndex} = wIndex
      {start, len} = partNumStartAndLen

      x = rem(start, rowLen)
      y = floor(start/rowLen)

      List.duplicate(:blah, len) 
      |> Enum.with_index()
      |> Enum.map(fn arg -> 
        {_, index} = arg

        touchedGears = []

        localX = x + index

        gear = ~r/\*/

        # IO.puts(Enum.at(grid, y) |> Enum.at(localX))

        isLeftGear = (localX > 0 && Regex.match?(gear, Enum.at(grid, y) |> Enum.at(localX - 1)))
        isUpGear = (y > 0 && Regex.match?(gear, Enum.at(grid, y - 1) |> Enum.at(localX)))
        isRightGear = (localX < (rowLen - 1) && Regex.match?(gear, Enum.at(grid, y) |> Enum.at(localX + 1)))
        isDownGear = (y < gridLen && Regex.match?(gear, Enum.at(grid, y + 1) |> Enum.at(localX)))
        isUpLeftGear = (localX > 0 && y > 0 && Regex.match?(gear, Enum.at(grid, y - 1) |> Enum.at(localX - 1)))
        isUpRightGear = (y > 0 && localX < (rowLen - 1) && Regex.match?(gear, Enum.at(grid, y - 1) |> Enum.at(localX + 1)))
        isDownRightGear = (y < gridLen && localX < (rowLen - 1) && Regex.match?(gear, Enum.at(grid, y + 1) |> Enum.at(localX + 1)))
        isDownLeftGear = (y < gridLen && localX > 0 && Regex.match?(gear, Enum.at(grid, y + 1) |> Enum.at(localX - 1)))
        
        leftGear = if (isLeftGear) do [localX - 1, y] else nil end
        upGear = if (isUpGear) do [localX, y - 1] else nil end
        rightGear = if (isRightGear) do [localX + 1, y] else nil end
        downGear = if (isDownGear) do [localX, y + 1] else nil end
        isUpLeftGear = if (isUpLeftGear) do [localX - 1, y - 1] else nil end
        isUpRightGear = if (isUpRightGear) do [localX + 1, y - 1] else nil end
        isDownRightGear = if (isDownRightGear) do [localX + 1, y + 1] else nil end
        isDownLeftGear = if (isDownLeftGear) do [localX - 1, y + 1] else nil end

        gears = [
          leftGear,
          upGear,
          rightGear,
          downGear,
          isUpLeftGear,
          isUpRightGear,
          isDownRightGear,
          isDownLeftGear
        ] 
        |> Enum.filter(fn potentialGearCoords -> potentialGearCoords != nil end)
        # |> IO.inspect()

       

        %{:num => Integer.parse(Enum.at(partNumActuals, partIndex)) |> elem(0), :gears => gears}

       

      end)
      |> Enum.filter(fn item -> 
        length(item[:gears]) > 0
      end)
      |> Enum.uniq()
      |> List.flatten()
      
    end)
    |> Enum.filter(fn item -> 
      length(item) > 0
    end)
    |> IO.inspect()
    

    gears = Enum.map(partsAndGears, fn partGearMap -> 
      Enum.at(partGearMap, 0)[:gears]
    end)
    |> Enum.reduce(%{}, fn curr, acc -> 
      Map.update(acc, curr, 1, fn existing_value -> existing_value + 1 end)
    end)
    |> Map.filter(fn {_key, value} -> 
      value == 2
    end)
    |> Enum.map(fn {gearsArr, _value} -> 
      Enum.at(gearsArr, 0)
    end)

    gearRatios = Enum.map(gears, fn gear -> 
      nums = Enum.filter(partsAndGears, fn partAndGear ->

        Enum.member?(Enum.at(partAndGear, 0)[:gears], gear)
      end)
      |> Enum.map(fn partAndGear -> 
        Enum.at(partAndGear, 0)[:num]
      end)
      |> IO.inspect()

    end)
    |> Enum.map(fn partNums -> 
      Enum.at(partNums, 0) * Enum.at(partNums, 1)
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)

  end
end
