defmodule AdventOfCode.Day23 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(23, 2023)

#     input = "#.#####################
# #.......#########...###
# #######.#########.#.###
# ###.....#.>.>.###.#.###
# ###v#####.#v#.###.#.###
# ###.>...#.#.#.....#...#
# ###v###.#.#.#########.#
# ###...#.#.#.......#...#
# #####.#.#.#######.#.###
# #.....#.#.#.......#...#
# #.#####.#.#.#########v#
# #.#...#...#...###...>.#
# #.#.#v#######v###.###v#
# #...#.>.#...>.>.#.###.#
# #####v#.#.###v#.#.###.#
# #.....#...#...#.#.#...#
# #.#########.###.#.#.###
# #...###...#...#...#.###
# ###.###.#.###v#####v###
# #...#...#.#.>.>.#.>.###
# #.###.###.#.###.#.#v###
# #.....###...###...#...#
# #####################.#"

    grid = Helpers.CalbeGrid.parse(input, "\n", "")

    #start is the first period in first row
    start_x = String.split(input, "\n", trim: true)
    |> Enum.at(0)
    |> String.split(".")
    |> Enum.at(0)
    |> String.length()

    #end is the first period in last row
    end_x = String.split(input, "\n", trim: true)
    |> Enum.at(-1)
    |> String.split(".")
    |> Enum.at(0)
    |> String.length()

    start_pos = {start_x, 0}
    end_pos = {end_x, Helpers.CalbeGrid.get_grid_len(grid) - 1}

    {grid, start_pos, end_pos}
  end

  defp naive_bfs(grid, start_pos, end_pos, paths) do

    terminated_paths = Enum.filter(paths, fn path -> 
      is_terminated = path[:terminated]
      is_terminated
    end)

    unterminated_paths = Enum.filter(paths, fn path -> 
      is_terminated = path[:terminated]
      !is_terminated
    end)

    if (unterminated_paths == []) do
      # IO.puts("no unterminated paths")
      paths
    else
      new_paths = Enum.flat_map(unterminated_paths, fn path -> 
        path_points = path[:path]
        is_terminated = path[:terminated]
        
        {last_x, last_y} = Enum.at(path_points, -1)
        last_val = Helpers.CalbeGrid.get_by_x_y(grid, last_x, last_y)
  
        if ({last_x, last_y} == end_pos) do
          [%{path: path_points, terminated: true}]
        else
  
          next_steps = case last_val do
            ">" -> [{last_x + 1, last_y}]
            "<" -> [{last_x - 1, last_y}]
            "^" -> [{last_x, last_y - 1}]
            "v" -> [{last_x, last_y + 1}]
            _ -> [
              {last_x + 1, last_y},
              {last_x - 1, last_y},
              {last_x, last_y + 1},
              {last_x, last_y - 1}
            ]
          end
          # |> IO.inspect([label: "next_steps", charlists: :as_lists])
          |> Enum.filter(fn {x, y} -> 
            !Enum.member?(path_points, {x, y})
          end)
          # |> Enum.filter(fn {x, y} -> 
          #    Enum.member?([".", ">", "<", "^", "v"], Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          # end)
          |> Enum.filter(fn {x, y} -> 
            val = Helpers.CalbeGrid.get_by_x_y(grid, x, y)
            cond do 
              val == "." -> true
              val == ">" && last_x < x -> true
              val == "<" && last_x > x -> true
              val == "^" && last_y > y -> true
              val == "v" && last_y < y -> true
              true -> false
            end
          end)
          # |> IO.inspect([label: "next_steps2", charlists: :as_lists])
    
          if next_steps == [] do
            # [%{path: path_points, terminated: true}]
            # IO.puts("!dead end??!")
            []
          else
            Enum.map(next_steps, fn {x, y} -> 
              %{path: path_points ++ [{x, y}], terminated: false}
            end)
          end
          
        end
  
      end)

      naive_bfs(grid, start_pos, end_pos, new_paths ++ terminated_paths)
    end

  end

  def part1(_args) do

    {grid, start_pos, end_pos} = get_parsed_input()

    Helpers.CalbeGrid.visualize_grid(grid)

    all_valid_paths = naive_bfs(grid, start_pos, end_pos, [%{path: [start_pos], terminated: false}])

    path_lengths = Enum.map(all_valid_paths, fn path -> 
      Enum.count(path[:path]) - 1
    end)
    |> IO.inspect([label: "path_lengths", charlists: :as_lists])

    Enum.max(path_lengths)

    


  end

  def part2(_args) do
  end
end
