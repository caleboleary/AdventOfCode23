defmodule AdventOfCode.Day14 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(14, 2023) 

#     input = "O....#....
# O.OO#....#
# .....##...
# OO.#O....O
# .O.....O#.
# O.#..O.#.#
# ..O..#O..O
# .......O..
# #....###..
# #OO..#...."

    Helpers.CalbeGrid.parse(input, "\n", "")

  end

  defp roll_rock(grid, {x, y}, direction) do

    directions = %{
      :north => {0, -1},
      :south => {0, 1},
      :east => {1, 0},
      :west => {-1, 0}
    }

    {x_step, y_step} = directions[direction]

    max_dist = if direction == :north || direction == :south do
      Helpers.CalbeGrid.get_grid_len(grid)
    else
      Helpers.CalbeGrid.get_grid_width(grid)
    end

    distance_rolled = Enum.reduce_while(1..max_dist, 0, fn dist, acc -> 
      x_new = x + (x_step * dist)
      y_new = y + (y_step * dist)

      value = Helpers.CalbeGrid.get_by_x_y(grid, x_new, y_new)

      if value == "O" || value == "#" || value == nil do
        {:halt, acc}
      else
        {:cont, acc + 1}
      end

    end)
    
    new_x = x + (x_step * distance_rolled)
    new_y = y + (y_step * distance_rolled)

    # IO.inspect({{x, y}, {new_x, new_y}}, label: "rock")

    grid = if distance_rolled > 0 do
      grid = Helpers.CalbeGrid.set_by_x_y(grid, x, y, ".")
      grid = Helpers.CalbeGrid.set_by_x_y(grid, new_x, new_y, "O")
    else
      grid
    end

  end

  defp roll_all_rocks(grid, direction) do

    round_rocks = Helpers.CalbeGrid.filter_points(grid, fn x -> x == "O" end)

    round_rocks = Enum.sort(round_rocks, fn {{x1, y1}, value1}, {{x2, y2}, value2} -> 

      cond do 
        direction == :north -> 
          y1 < y2
        direction == :south -> 
          y1 > y2
        direction == :east -> 
          x1 > x2
        direction == :west -> 
          x1 < x2
      end

    end)

    Enum.reduce(round_rocks, grid, fn {{x, y}, value}, acc -> 
      # IO.inspect({{x, y}, value}, label: "rock")
      roll_rock(acc, {x, y}, direction)
    end)

  end

  defp calculate_load(grid, tilt_dir) do
    round_rocks = Helpers.CalbeGrid.filter_points(grid, fn x -> x == "O" end)

    grid_len = Helpers.CalbeGrid.get_grid_len(grid)
    grid_width = Helpers.CalbeGrid.get_grid_width(grid)

    Enum.reduce(round_rocks, 0, fn {{x, y}, value}, acc -> 

      load = case tilt_dir do
        :north -> 
          grid_len - y
        :south -> 
          y
        :east -> 
          grid_width - x
        :west -> 
          x
      end

      acc + load
      
    end)
  end

  def part1(_args) do

    input = get_parsed_input()

    Helpers.CalbeGrid.visualize_grid(input)

    rolled = roll_all_rocks(input, :north)
    |> Helpers.CalbeGrid.visualize_grid()

    calculate_load(rolled, :north)
    
  end

  defp run_cycle(grid) do
    rolled = roll_all_rocks(grid, :north)
    |> roll_all_rocks(:west)
    |> roll_all_rocks(:south)
    |> roll_all_rocks(:east)
  end

  def part2(_args) do

    input = get_parsed_input()

    Helpers.CalbeGrid.visualize_grid(input)

    #run 100 cycles
    loads_after_cycles = Enum.reduce(1..1000, %{latest: input, loads: []}, fn cycle, acc -> 
      new_grid = run_cycle(acc[:latest])

      load = calculate_load(new_grid, :north)
      # |> IO.inspect(label: "load")

      %{latest: new_grid, loads: acc.loads ++ [load]}
    end)

    #drop the first 200 loads
    loads_after_cycles_to_find_cycle = %{loads: Enum.slice(loads_after_cycles[:loads], 200, 1000)}
  
    Helpers.Utils.inspect(loads_after_cycles[:loads])
    |> Helpers.Utils.dump_to_file("loads.txt")

    #identify cycle length
    cycle_length = Enum.reduce_while(1..500, nil, fn cycle, acc -> 
      chunked = Enum.chunk_every(loads_after_cycles_to_find_cycle[:loads], cycle)
      |> Enum.drop(-1)
      |> IO.inspect([label: "chunked", charlists: :as_lists])

      #if all chunks are equal, we've found the cycle length
      if Enum.all?(chunked, fn x -> x == Enum.at(chunked, 0) end) do
        # IO.inspect(cycle, label: "halting")
        {:halt, cycle}
      else
        {:cont, acc}
      end
    end)
    |> IO.inspect(label: "cycle length")

    offset = Enum.reduce_while(0..1000, nil, fn index, acc -> 
      loads = loads_after_cycles[:loads]

      if Enum.slice(loads, index, cycle_length) == Enum.slice(loads, index + cycle_length, cycle_length) do
        {:halt, index}
      else
        {:cont, acc}
      end
    end)
    |> IO.inspect(label: "offset")

    complete_cycle = Enum.slice(loads_after_cycles[:loads], offset, cycle_length)

    IO.inspect(complete_cycle, [label: "complete cycle", charlists: :as_lists])

    Enum.at(complete_cycle, rem(1000000000 - offset, cycle_length) - 1)

  end
end
