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

  defp get_nodes(grid) do

    Enum.reduce(0..(Helpers.CalbeGrid.get_grid_len(grid) - 1), [], fn y, acc -> 
      Enum.reduce(0..(Helpers.CalbeGrid.get_grid_len(grid) - 1), acc, fn x, acc -> 
        point = Helpers.CalbeGrid.get_by_x_y(grid, x, y)
        north = Helpers.CalbeGrid.get_by_x_y(grid, x, y - 1)
        south = Helpers.CalbeGrid.get_by_x_y(grid, x, y + 1)
        west = Helpers.CalbeGrid.get_by_x_y(grid, x - 1, y)
        east = Helpers.CalbeGrid.get_by_x_y(grid, x + 1, y)

        if (
          point == "."
           && length(Enum.filter([north, south, west, east], fn val -> Enum.member?([".", ">", "v", "<", "^"], val) end)) >= 3
        ) do
          acc ++ [{x, y}]
        else
          acc
        end
      end)
    end)
    
  end

  defp bfs_to_nodes(grid, nodes, start_pos, terminated_paths, unterminated_paths, depth) do

    # IO.inspect(unterminated_paths, [label: "unterminated_paths_invoked", charlists: :as_lists])

    new_paths = Enum.flat_map(unterminated_paths, fn path -> 
      path_points = path[:path]
      is_terminated = path[:terminated]
      visited = path[:visited]
      
      # IO.inspect(path_points, [label: "path_points", charlists: :as_lists])
      {last_x, last_y} = Enum.at(path_points, -1)
      # |> IO.inspect([label: "last_x, last_y", charlists: :as_lists])

      last_val = Helpers.CalbeGrid.get_by_x_y(grid, last_x, last_y)

      if (Enum.member?(nodes, {last_x, last_y}) && depth > 0) do
        [%{path: path_points, terminated: true}]
      else

        next_steps = [
          {last_x + 1, last_y},
          {last_x - 1, last_y},
          {last_x, last_y + 1},
          {last_x, last_y - 1}
        ]
        |> Enum.filter(fn {x, y} -> 
          !visited[[x, y]]
        end)
        |> Enum.filter(fn {x, y} -> 
           Enum.member?([".", ">", "<", "^", "v"], Helpers.CalbeGrid.get_by_x_y(grid, x, y))
        end)

        if next_steps == [] do
          IO.puts("!dead end??!")
          []
        else
          Enum.map(next_steps, fn {x, y} -> 
            %{path: path_points ++ [{x, y}], terminated: false, visited: Map.put(visited, [x, y], true)}
          end)
        end
        
      end

    end)
    # |> IO.inspect([label: "new_paths", charlists: :as_lists])

    new_terminated_paths = Enum.filter(new_paths, fn path -> 
      path[:terminated]
    end)
    # |> IO.inspect([label: "new_terminated_paths", charlists: :as_lists])

    new_unterminated_paths = Enum.filter(new_paths, fn path -> 
      !path[:terminated]
    end)
    # |> IO.inspect([label: "new_unterminated_paths", charlists: :as_lists])

    if (length(new_unterminated_paths) > 0) do
      bfs_to_nodes(grid, nodes, start_pos, terminated_paths ++ new_terminated_paths, new_unterminated_paths, depth + 1)
    else
      terminated_paths ++ new_terminated_paths
    end
  end

  defp get_node_connections(grid, nodes) do

    Enum.reduce(nodes, %{}, fn {x, y}, acc -> 

      all_paths_to_other_nodes = bfs_to_nodes(
        grid, 
        nodes,
        {x, y},
        [], 
        [
          %{
            path: [{x, y}], 
            terminated: false, 
            visited: Map.put(%{}, [x, y], true)
          }
        ], 
        0
      )
      # |> IO.inspect([label: "all_paths_to_other_nodes for #{x}, #{y}", charlists: :as_lists])

      connections = Enum.map(all_paths_to_other_nodes, fn path -> 
        %{
          connection: Enum.at(path[:path], -1),
          length: Enum.count(path[:path]) - 1
        }
      end)

      Map.put(acc, {x, y}, connections)
      
      
    end)

  end

  defp node_bfs(node_graph, start_pos, end_pos, terminated_paths, unterminated_paths, depth) do

    IO.puts("depth: #{depth}")

    if (rem(depth, 5) == 0) do
      unterm_breadth = Enum.count(unterminated_paths)
      IO.puts("unterm_breadth: #{unterm_breadth}")
    end

    if (unterminated_paths == []) do
      terminated_paths
    else
      new_paths = Enum.flat_map(unterminated_paths, fn path -> 
        path_points = path[:path]
        is_terminated = path[:terminated]
        visited = path[:visited]
        length = path[:length]
        
        last = Enum.at(path_points, -1)

        if (last == end_pos) do
          [%{path: path_points, terminated: true, length: length}]
        else

          connections = node_graph[last]

          next_steps = Enum.map(connections, fn connection -> 
            connection[:connection]
          end)
          |> Enum.filter(fn {x, y} -> 
            !visited[[x, y]]
          end)

          if next_steps == [] do
            # IO.puts("!dead end??!")
            []
          else
            Enum.map(next_steps, fn {x, y} -> 

              connection = Enum.find(connections, fn connection -> 
                connection[:connection] == {x, y}
              end)

              added_len = connection[:length]

              %{path: path_points ++ [{x, y}], terminated: false, visited: Map.put(visited, [x, y], true), length: length + added_len}
            end)
          end
          
        end
  
      end)

      new_terminated_paths = Enum.filter(new_paths, fn path -> 
        is_terminated = path[:terminated]
        is_terminated
      end)

      new_unterminated_paths = Enum.filter(new_paths, fn path -> 
        is_terminated = path[:terminated]
        !is_terminated
      end)

      if (length(new_unterminated_paths) > 0) do
        node_bfs(node_graph, start_pos, end_pos, new_terminated_paths ++ terminated_paths, new_unterminated_paths, depth + 1)
      else
        new_terminated_paths ++ terminated_paths
      end
    end

  end

  def part2(_args) do
    {grid, start_pos, end_pos} = get_parsed_input()

    Helpers.CalbeGrid.visualize_grid(grid)
    
    nodes = (get_nodes(grid) ++ [start_pos, end_pos])
    |> IO.inspect([label: "nodes", charlists: :as_lists])

    node_connections = get_node_connections(grid, nodes)
    |> IO.inspect([label: "node_connections", charlists: :as_lists])

    all_valid_paths = node_bfs(node_connections, start_pos, end_pos, [], [%{path: [start_pos], terminated: false, visited: %{start_pos => true}, length: 0}], 0)

    longest_path = Enum.max_by(all_valid_paths, fn path -> 
      path[:length]
    end)

  end
end
