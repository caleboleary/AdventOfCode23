defmodule AdventOfCode.Day13 do

  defp get_parsed_input() do

    input = AdventOfCode.Input.get!(13, 2023) 

#     input = "##....##.#.
# ##.##.#..#.
# ..####....#
# #######..##
# ##..#......
# ...##......
# ###....##..
# ..#.#..##..
# ...#.#....#
# ..##.......
# ..##.#.##.#
# ##...##..##
# ######.##.#
# ###...#..#.
# ...###....#
# ..##.......
# ###.##....#"

#     input = "#.##..##.
# ..#.##.#.
# ##......#
# ##......#
# ..#.##.#.
# ..##..##.
# #.#.##.#.

# #...##..#
# #....#..#
# ..##..###
# #####.##.
# #####.##.
# ..##..###
# #....#..#"

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

  defp get_vertical_reflection_line(grid, ignore \\ nil) do
    # a reflection line of index 0 means between 0 and 1 here. I will have to increment later I think when I sum.
    potential_reflection_lines = Enum.filter(0..Helpers.CalbeGrid.get_grid_width(grid) - 2, fn index ->
      Helpers.CalbeGrid.get_col(grid, index) == Helpers.CalbeGrid.get_col(grid, index + 1)
    end)
    # |> IO.inspect([charlists: :as_lists, label: "potential_reflection_lines"])
    |> Enum.filter(fn index ->
      index != ignore
    end)
    # |> IO.inspect([charlists: :as_lists, label: "post filter"])

    Enum.find(potential_reflection_lines, fn line_idx ->
      # if (line_idx == 7) do
        # IO.inspect({line_idx, ignore}, label: "line_idx, ignore")
        # IO.inspect(get_is_vertical_line_full_reflection(grid, line_idx), label: "get_is_vertical_line_full_reflection(grid, line_idx)")
      # end
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

  defp get_horizontal_reflection_line(grid, ignore \\ nil) do
    potential_reflection_lines = Enum.filter(0..Helpers.CalbeGrid.get_grid_len(grid) - 2, fn index ->
      Helpers.CalbeGrid.get_row(grid, index) == Helpers.CalbeGrid.get_row(grid, index + 1)
    end)
    |> Enum.filter(fn index ->
      index != ignore
    end)

    Enum.find(potential_reflection_lines, fn line_idx ->
      get_is_horizontal_line_full_reflection(grid, line_idx)
    end)
  end

  defp get_vert_and_horiz_reflection_lines(grid, {ignore_vert, ignore_horiz} \\  {nil, nil}) do
    vert_mirror_line = get_vertical_reflection_line(grid, ignore_vert)

    horiz_mirror_line = get_horizontal_reflection_line(grid, ignore_horiz)

    {vert_mirror_line, horiz_mirror_line}
  end

  def part1(_args) do

    input = get_parsed_input()


    Enum.map(input, fn grid ->

      {vert_mirror_line, horiz_mirror_line} = get_vert_and_horiz_reflection_lines(grid)

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

  defp fix_that_smudge(grid) do

    {original_vert_line, original_horiz_line} = get_vert_and_horiz_reflection_lines(grid)
    # |> IO.inspect(label: "original_vert_line, original_horiz_line")

    # for every row, for every column, switch the value of . to # or # to . and then get the reflection lines
    # if both are nil, keep going, if we get one, stop and return both
    Enum.reduce_while(0..(Helpers.CalbeGrid.get_grid_len(grid) - 1), {nil, nil}, fn y, _acc ->
      row_res = Enum.reduce_while(0..(Helpers.CalbeGrid.get_grid_width(grid) - 1), {nil, nil}, fn x, _acc ->
        cell = Helpers.CalbeGrid.get_by_x_y(grid, x, y)
        # |> IO.inspect(label: "cell")

        # Helpers.CalbeGrid.visualize_grid(grid)

        new_grid = if cell == "." do
          Helpers.CalbeGrid.set_by_x_y(grid, x, y, "#")
        else
          Helpers.CalbeGrid.set_by_x_y(grid, x, y, ".")
        end

        # if (x == 7 && y == 0) do
        #   IO.inspect({x, y}, label: "x, y")
        #   Helpers.CalbeGrid.visualize_grid(new_grid)
        #   IO.inspect({x, y}, label: "x, y")

        #   IO.inspect(get_vert_and_horiz_reflection_lines(new_grid), label: "get_vert_and_horiz_reflection_lines(new_grid)")
        # end

        # IO.inspect("---")

        # Helpers.CalbeGrid.visualize_grid(new_grid)

        {new_vert_mirror_line, new_horiz_mirror_line} = get_vert_and_horiz_reflection_lines(new_grid, {original_vert_line, original_horiz_line})
        # |> IO.inspect(label: "new_vert_mirror_line, new_horiz_mirror_line")
       
        if (new_vert_mirror_line != nil) || (new_horiz_mirror_line != nil) do
          {:halt, {new_vert_mirror_line, new_horiz_mirror_line}}
        else
          {:cont, {nil, nil}}
        end
      end)

      if row_res == {nil, nil} do
        {:cont, {nil, nil}}
      else
        {:halt, row_res}
      end
    end)

  end

  def part2(_args) do

    input = get_parsed_input()


    Enum.map(input, fn grid ->

      {vert_mirror_line, horiz_mirror_line} = fix_that_smudge(grid)
      # |> IO.inspect(label: "smudge fixed")

      if (vert_mirror_line == nil && horiz_mirror_line == nil) do
        Helpers.CalbeGrid.visualize_grid(grid)
        IO.inspect({vert_mirror_line, horiz_mirror_line}, label: "no smudge found??")
      end
      
      if vert_mirror_line != nil do
        vert_mirror_line + 1
      else
        (horiz_mirror_line + 1) * 100
      end
    end)
    # |> IO.inspect(label: "result")
    |> Enum.sum()

  end
end
