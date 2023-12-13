defmodule AdventOfCode.Day13 do

  defp get_parsed_input() do

    input = AdventOfCode.Input.get!(13, 2023) 

    input = "#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"

    String.split(input, "\n\n", trim: true)
    |> Enum.map(fn line ->
      Helpers.CalbeGrid.parse(line, "\n", "")
    end)

  end

  defp get_is_vertical_line_full_reflection(grid, line_idx) do
    grid_width = Helpers.CalbeGrid.get_grid_width(grid)

    cols_to_check = min(line_idx + 1, grid_width - line_idx - 1)
    
    Enum.reduce(1..cols_to_check, true, fn col_idx, acc ->
      
      cols = {line_idx - (col_idx - 1), line_idx + col_idx}
      # |> IO.inspect(label: "cols")

      acc && Helpers.CalbeGrid.get_col(grid, cols |> elem(0)) == Helpers.CalbeGrid.get_col(grid, cols |> elem(1))
    end)
    # |> IO.inspect(label: line_idx)

  end

  defp get_vertical_reflection_line(grid) do
    # a reflection line of index 0 means between 0 and 1 here. I will have to increment later I think when I sum.
    potential_reflection_lines = Enum.filter(0..Helpers.CalbeGrid.get_grid_width(grid) - 2, fn index ->
      Helpers.CalbeGrid.get_col(grid, index) == Helpers.CalbeGrid.get_col(grid, index + 1)
    end)
    # |> IO.inspect([charlists: :as_lists])

    Enum.find(potential_reflection_lines, fn line_idx ->
      get_is_vertical_line_full_reflection(grid, line_idx)
    end)
  end

  defp get_is_horizontal_line_full_reflection(grid, line_idx) do
    grid_len = Helpers.CalbeGrid.get_grid_len(grid)

    # IO.inspect(line_idx, label: "line_idx")

    rows_to_check = min(line_idx + 1, grid_len - line_idx - 1)
    # |> IO.inspect(label: "rows_to_check")
    
    Enum.reduce(1..rows_to_check, true, fn row_idx, acc ->
      
      rows = {line_idx - (row_idx - 1), line_idx + row_idx}
      # |> IO.inspect(label: "rows")

      row1 = Helpers.CalbeGrid.get_row(grid, rows |> elem(0))
      row2 = Helpers.CalbeGrid.get_row(grid, rows |> elem(1))

      # IO.inspect({row1, row2}, label: "rows")
      

      acc && row1 == row2
    end)
    # |> IO.inspect(label: line_idx)

  end

  defp get_horizontal_reflection_line(grid) do
    potential_reflection_lines = Enum.filter(0..Helpers.CalbeGrid.get_grid_len(grid) - 2, fn index ->
      Helpers.CalbeGrid.get_row(grid, index) == Helpers.CalbeGrid.get_row(grid, index + 1)
    end)
    # |> IO.inspect([charlists: :as_lists])

    Enum.find(potential_reflection_lines, fn line_idx ->
      get_is_horizontal_line_full_reflection(grid, line_idx)
    end)
  end

  def part1(_args) do

    input = get_parsed_input()


    Enum.map(input, fn grid ->

      # Helpers.CalbeGrid.visualize_grid(grid)

      vert_mirror_line = get_vertical_reflection_line(grid)
      # |> IO.inspect(label: "vert_mirror_line")

      horiz_mirror_line = get_horizontal_reflection_line(grid)
      # |> IO.inspect(label: "horiz_mirror_line")

      if (vert_mirror_line != nil && horiz_mirror_line != nil) do
        Helpers.CalbeGrid.visualize_grid(grid)
        IO.inspect({vert_mirror_line, horiz_mirror_line}, label: "vert_mirror_line, horiz_mirror_line")
      end

      if vert_mirror_line != nil do
        vert_mirror_line + 1
      else
        (horiz_mirror_line + 1) * 100
      end
    end)
    |> Enum.sum()

  end

  def part2(_args) do
  end
end
