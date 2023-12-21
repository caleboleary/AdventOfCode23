defmodule AdventOfCode.Day21 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(21, 2023)

    input = "...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
..........."

    Helpers.CalbeGrid.parse(input, "\n", "")
  end

  defp get_viable_moves(grid, pos) do
    {x, y} = pos

    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
    |> Enum.filter(fn pos -> 
      {x, y} = pos
      value = Helpers.CalbeGrid.get_by_x_y(grid, x, y)

      value != nil && value != "#"
    end)
  end

  defp bfs(grid, positions, depth, max_depth) do
    if (depth == max_depth) do
    # if (depth == 6) do
      positions
    else
      new_positions = Enum.flat_map(positions, fn pos -> 
        get_viable_moves(grid, pos)
      end)
      |> Enum.uniq()

      bfs(grid, new_positions, depth + 1, max_depth)
    end
  end

  def part1(_args) do

    input = get_parsed_input()

    start_pos = Helpers.CalbeGrid.find_point(input, fn cell -> cell == "S" end)

    Helpers.CalbeGrid.visualize_grid(input)

    results = bfs(input, [start_pos], 0, 6)
    |> length()

  end

  def part2(_args) do
  end
end
