defmodule AdventOfCode.Day11 do

  defp get_parsed_input() do

    input = AdventOfCode.Input.get!(11, 2023) 

#     input = "...#......
# .......#..
# #.........
# ..........
# ......#...
# .#........
# .........#
# ..........
# .......#..
# #...#....."

  end

  defp get_all_galaxy_pairs(galaxy_positions) do
     # https://elixirforum.com/t/generate-all-combinations-having-a-fixed-array-size/26196/17
     (for x <- galaxy_positions, y <- galaxy_positions, x != y, do: [x, y])
     |> Enum.map(fn [{x, _}, {y, _}] -> [x, y] end)
     |> Enum.map(fn [x, y] -> [x, y] |> Enum.sort() end)
     |> Enum.uniq()
    #  |> IO.inspect()
  end

  defp get_distance_between_2_galaxies(galaxy1, galaxy2, columns_without_galaxies, rows_without_galaxies) do
    {x1, y1} = galaxy1
    {x2, y2} = galaxy2
    # IO.inspect({galaxy1, galaxy2}, label: "get_distance_between_2_galaxies")

    x_distance = abs(x1 - x2)
    y_distance = abs(y1 - y2)

    base_dist = x_distance + y_distance
    # |> IO.inspect(label: "base_dist")

    count_of_rows_without_galaxies_crossed = Enum.filter(rows_without_galaxies, fn row -> 
      # IO.inspect({row, y1, y2}, label: "row")
      row > min(y1, y2) && row < max(y1, y2)
    end) |> length()
    # |> IO.inspect(label: "count_of_rows_without_galaxies_crossed")

    count_of_columns_without_galaxies_crossed = Enum.filter(columns_without_galaxies, fn column -> 
      column > min(x1, x2) && column < max(x1, x2)
    end) |> length()
    # |> IO.inspect(label: "count_of_columns_without_galaxies_crossed")

    base_dist + count_of_rows_without_galaxies_crossed + count_of_columns_without_galaxies_crossed
    # |> IO.inspect(label: "base_dist + count_of_rows_without_galaxies_crossed + count_of_columns_without_galaxies_crossed")
  end

  defp get_distance_between_2_galaxies_p2(galaxy1, galaxy2, columns_without_galaxies, rows_without_galaxies) do
    {x1, y1} = galaxy1
    {x2, y2} = galaxy2
    # IO.inspect({galaxy1, galaxy2}, label: "get_distance_between_2_galaxies")

    x_distance = abs(x1 - x2)
    y_distance = abs(y1 - y2)

    base_dist = x_distance + y_distance
    # |> IO.inspect(label: "base_dist")

    count_of_rows_without_galaxies_crossed = Enum.filter(rows_without_galaxies, fn row -> 
      # IO.inspect({row, y1, y2}, label: "row")
      row > min(y1, y2) && row < max(y1, y2)
    end) |> length()
    # |> IO.inspect(label: "count_of_rows_without_galaxies_crossed")

    count_of_columns_without_galaxies_crossed = Enum.filter(columns_without_galaxies, fn column -> 
      column > min(x1, x2) && column < max(x1, x2)
    end) |> length()
    # |> IO.inspect(label: "count_of_columns_without_galaxies_crossed")

    base_dist + (count_of_rows_without_galaxies_crossed * 999999) + (count_of_columns_without_galaxies_crossed * 999999)
    # |> IO.inspect(label: "base_dist + count_of_rows_without_galaxies_crossed + count_of_columns_without_galaxies_crossed")
  end

  defp get_columns_without_galaxies(grid, galaxy_positions) do
    Enum.reduce(0..(Helpers.CalbeGrid.get_grid_width(grid) - 1), [], fn x, acc -> 
      if Enum.any?(galaxy_positions, fn galaxy_pos -> 
        {{x_coord, y}, value} = galaxy_pos
        x_coord == x
      end) do
        acc
      else
        [x | acc]
      end
    end)
  end

  defp get_rows_without_galaxies(grid, galaxy_positions) do 
    Enum.reduce(0..(Helpers.CalbeGrid.get_grid_len(grid) - 1), [], fn y, acc -> 
      if Enum.any?(galaxy_positions, fn galaxy_pos -> 
        {{x, y_coord}, value}= galaxy_pos
        y_coord == y
      end) do
        acc
      else
        [y | acc]
      end
    end)
  end

  def part1(_args) do

    input = get_parsed_input()

    grid = Helpers.CalbeGrid.parse(input, "\n", "")
    
    Helpers.CalbeGrid.visualize_grid(grid)

    galaxy_positions = Helpers.CalbeGrid.filter_points(grid, fn x -> x == "#" end)

    all_galaxy_pairs = get_all_galaxy_pairs(galaxy_positions)

    columns_without_galaxies = get_columns_without_galaxies(grid, galaxy_positions)

    rows_without_galaxies = get_rows_without_galaxies(grid, galaxy_positions)

    Enum.map(all_galaxy_pairs, fn [galaxy1, galaxy2] -> 
      dist = get_distance_between_2_galaxies(galaxy1, galaxy2, columns_without_galaxies, rows_without_galaxies)
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)


  end

  def part2(_args) do

    input = get_parsed_input()

    grid = Helpers.CalbeGrid.parse(input, "\n", "")
    
    Helpers.CalbeGrid.visualize_grid(grid)

    galaxy_positions = Helpers.CalbeGrid.filter_points(grid, fn x -> x == "#" end)

    all_galaxy_pairs = get_all_galaxy_pairs(galaxy_positions)

    columns_without_galaxies = get_columns_without_galaxies(grid, galaxy_positions)

    rows_without_galaxies = get_rows_without_galaxies(grid, galaxy_positions)

    Enum.map(all_galaxy_pairs, fn [galaxy1, galaxy2] -> 
      dist = get_distance_between_2_galaxies_p2(galaxy1, galaxy2, columns_without_galaxies, rows_without_galaxies)
    end)
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)
  end
end
