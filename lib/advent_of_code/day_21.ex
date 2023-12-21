defmodule AdventOfCode.Day21 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(21, 2023)
    # 29722 - magic num

#     input = "...........
# .....###.#.
# .###.##..#.
# ..#.#...#..
# ....#.#....
# .##..S####.
# .##..#...#.
# .......##..
# .##.#.####.
# .##..##.##.
# ..........."

# input = ".................................
# .....###.#......###.#......###.#.
# .###.##..#..###.##..#..###.##..#.
# ..#.#...#....#.#...#....#.#...#..
# ....#.#........#.#........#.#....
# .##...####..##...####..##...####.
# .##..#...#..##..#...#..##..#...#.
# .......##.........##.........##..
# .##.#.####..##.#.####..##.#.####.
# .##..##.##..##..##.##..##..##.##.
# .................................
# .................................
# .....###.#......###.#......###.#.
# .###.##..#..###.##..#..###.##..#.
# ..#.#...#....#.#...#....#.#...#..
# ....#.#........#.#........#.#....
# .##...####..##..S####..##...####.
# .##..#...#..##..#...#..##..#...#.
# .......##.........##.........##..
# .##.#.####..##.#.####..##.#.####.
# .##..##.##..##..##.##..##..##.##.
# .................................
# .................................
# .....###.#......###.#......###.#.
# .###.##..#..###.##..#..###.##..#.
# ..#.#...#....#.#...#....#.#...#..
# ....#.#........#.#........#.#....
# .##...####..##...####..##...####.
# .##..#...#..##..#...#..##..#...#.
# .......##.........##.........##..
# .##.#.####..##.#.####..##.#.####.
# .##..##.##..##..##.##..##..##.##.
# ................................."

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

  defp get_viable_moves_p2(grid, pos) do
    {x, y} = pos

    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
    |> Enum.filter(fn pos -> 
      {x, y} = pos
      value = get_by_x_y_wrapping(grid, x, y)

      value != "#"
    end)
  end

  defp bfs_p2(grid, positions, depth, max_depth, all_positions) do
    IO.inspect(depth, [label: "depth"])
    if (depth == max_depth) do
      {positions, all_positions}
    else
      new_positions = Enum.flat_map(positions, fn pos -> 
        memoized(pos, fn -> get_viable_moves_p2(grid, pos) end)
      end)
      |> Enum.uniq()

      bfs_p2(grid, new_positions, depth + 1, max_depth, all_positions ++ [{depth, length(new_positions)}])
    end
  end

  def get_by_x_y_wrapping(grid, x, y) do
  
    grid_len = Helpers.CalbeGrid.get_grid_len(grid)
    grid_width = Helpers.CalbeGrid.get_grid_width(grid)

    x_wrapped = if (x < 0) do
      grid_width - rem(abs(x), grid_width)
    else
      rem(x, grid_width)
    end
    |> abs()

    y_wrapped = if (y < 0) do
      grid_len - rem(abs(y), grid_len)
    else
      rem(y, grid_len)
    end
    |> abs()

    grid[{x_wrapped, y_wrapped}]

  end

  defp subtract_lists(list1, list2) do
    Enum.with_index(list2)
    |> Enum.map(fn {item, index} -> 
      if (index >= length(list1) - 1) do
        0
      else
        next = Enum.at(list1, index)

        next - item
      end

    end)
  end

  defp magic_math(fifth_row, sixth_row, target_steps_count, magic_number) do
    #so for the sample, I know that to go from the 55th item to the 66th, I need to add 162 (magic num) to the difference between the 44th and 55th

    # I need to figure out how to math this for any arbitrary input

    fifth_row_base = Enum.at(fifth_row, rem(target_steps_count, length(fifth_row)))
    sixth_row_base = Enum.at(sixth_row, rem(target_steps_count, length(sixth_row)))

    diff = sixth_row_base - fifth_row_base
    |> IO.inspect([label: "diff", charlists: :as_lists])
    

    # diff + (magic_number * (target_steps_count - 44))

    #and now I'll need to do some math maybe similar to like compound interest or something 

    
    #example, the answer for 66 steps = 2882
    # the fifth_row_base would be 1256 as that's the first entry in the fifth row
    # and the sample grid is 11 wide, and rem(66, 11) = 0, so the 66th item is the first item in the fifth row

    # IO.inspect(floor((target_steps_count - 44)/11), [label: "floor((target_steps_count - 44)/11)"])

    # fifth_row_base + diff + (magic_number * floor((target_steps_count - 44)/11))

    n = floor((target_steps_count - (length(fifth_row) * 4))/length(fifth_row)) - 1

    # 744(n + 1) + 162 * [n(n + 1)/2]
    fifth_row_base + (diff * (n + 1)) + (magic_number * (n * (n + 1) / 2))

  end

  def part2(_args) do

    input = get_parsed_input()

    start_pos = Helpers.CalbeGrid.find_point(input, fn cell -> cell == "S" end)

    Helpers.CalbeGrid.visualize_grid(input)

    width = Helpers.CalbeGrid.get_grid_width(input)

    max_depth = 7 * width
    # tests = [10]


    {last, all} = bfs_p2(input, [start_pos], 0, max_depth, [])

    chunks = all
      |> Enum.map(fn {depth, count} -> 
        count
      end)
      |> Helpers.Utils.dump_to_file("day_21_p2")
      #remove the first (width * 2) elements
      |> Enum.drop(width * 4)
      |> Enum.chunk_every(width)
      |> IO.inspect(charlists: :as_lists)
    |> Enum.with_index()


    diffs_from_prev_chunk = Enum.map(chunks, fn {row, index} -> 
      if (index == length(chunks) - 1) do
        []
      else
        {next, _i} = Enum.at(chunks, index + 1)

        subtract_lists(next, row)
      end
      
    end)
    |> IO.inspect(charlists: :as_lists)

    diffs_from_diffs = Enum.with_index(diffs_from_prev_chunk)
    |> Enum.map(fn {row, index} -> 
      if (index == length(diffs_from_prev_chunk) - 1) do
        []
      else
        next = Enum.at(diffs_from_prev_chunk, index + 1)
        # IO.inspect(next, [label: "next"])
        # IO.inspect(row, [label: "row"])

        subtract_lists(next, row)
      end
      
    end)
    |> IO.inspect(charlists: :as_lists)

    fifth_row = Enum.at(chunks, 0) 
    |> elem(0)
    |> IO.inspect([label: "fifth_row", charlists: :as_lists])

    sixth_row = Enum.at(chunks, 1)
    |> elem(0)
    |> IO.inspect([label: "sixth_row", charlists: :as_lists])

    magic_number = Enum.at(diffs_from_diffs, 0) |> Enum.at(0)
    |> IO.inspect([label: "magic_number", charlists: :as_lists])

    magic_math(fifth_row, sixth_row, (26501365 - 1), magic_number)
    # 86257918209104860 too high

    
    # Enum.with_index(res)
    # |> Enum.map(fn {result, index} -> 
    #   if (index == length(res) - 1) do
    #     0
    #   else
    #     next = Enum.at(res, index + 1)

    #     next - result
    #   end

    # end)
    # |> Helpers.Utils.dump_to_file("day_21_p2_diffs")
    # |> Enum.chunk_every(11)
    # |> IO.inspect(charlists: :as_lists)

  end

  # https://github.com/michaelst/aoc/blob/main/lib/advent_of_code/day_12.ex
  defp memoized(key, fun) do
    with nil <- Process.get(key) do
      fun.() |> tap(&Process.put(key, &1))
    end
  end
end
