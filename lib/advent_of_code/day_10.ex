defmodule AdventOfCode.Day10 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(10, 2023) 

#     input = "7-F7-
# .FJ|7
# SJLL7
# |F--J
# LJ.LJ"

    grid = Helpers.CalbeGrid.parse(input, "\n", "")

  end

  def get_allowed_directions(symbol) do 
    case symbol do
      "S" -> [:north, :south, :east, :west]
      "7" -> [:west, :south]
      "F" -> [:east, :south]
      "L" -> [:north, :east]
      "J" -> [:north, :west]
      "|" -> [:north, :south]
      "-" -> [:east, :west]
      _ -> []
    end
  end

  def crawl_main_loop(grid, path, depth) do
    IO.inspect(path, label: "path")

    valid_north_connections = ["|", "7", "F", "S"]
    valid_south_connections = ["|", "L", "J", "S"]
    valid_east_connections = ["-", "J", "7", "S"]
    valid_west_connections = ["-", "L", "F", "S"]

    {latest_x, latest_y} = List.last(path)

    if (depth > 0 && Helpers.CalbeGrid.get_by_x_y(grid, latest_x, latest_y) == "S") do
      path
    else
      {second_latest_x, second_latest_y} = if (depth > 0) do
        Enum.at(path, -2)
      else
        {:none, :none}
      end

      possible_moves = [
        {0, -1, :north},
        {0, 1, :south},
        {1, 0, :east},
        {-1, 0, :west}
      ]
      |> Enum.filter(fn {_x, _y, dir} -> 
        Enum.member?(get_allowed_directions(Helpers.CalbeGrid.get_by_x_y(grid, latest_x, latest_y)), dir)
      end)
      |> Enum.map(fn {x, y, dir} -> 
        {x + latest_x, y + latest_y, dir}
      end)
      |> Enum.filter(fn {x, y, _dir} -> 
        (x != second_latest_x || y != second_latest_y) || depth == 0
      end)
      |> IO.inspect(label: "possible_moves")

      # i'm making an assumption here there will only ever be one valid move, when excluding where we came from.
      # when we're at S at depth 0, we can just pick one at random I think so find is fine.
      valid_move = Enum.find(possible_moves, fn {x, y, dir} -> 
        IO.inspect({x, y, dir})
        IO.inspect(Helpers.CalbeGrid.get_by_x_y(grid, x, y))
        IO.inspect(valid_south_connections)

        case dir do
          :north -> Enum.member?(valid_north_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          :south -> Enum.member?(valid_south_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          :east -> Enum.member?(valid_east_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          :west -> Enum.member?(valid_west_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
        end
      end)
      |> IO.inspect(label: "valid_move")


      {valid_x, valid_y, _valid_dir} = valid_move

      crawl_main_loop(grid, path ++ [{valid_x, valid_y}], depth + 1)
    end

  end

  def part1(_args) do

    input = get_parsed_input()

    start = Helpers.CalbeGrid.find_point(input, fn x -> x == "S" end)

    main_loop = crawl_main_loop(input, [start], 0)
    |> IO.inspect(label: "main_loop")
   

    (length(main_loop) - 1) / 2
  end

  def part2(_args) do
  end
end
