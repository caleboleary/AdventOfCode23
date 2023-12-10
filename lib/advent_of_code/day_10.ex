defmodule AdventOfCode.Day10 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(10, 2023) 

#     input = "7-F7-
# .FJ|7
# SJLL7
# |F--J
# LJ.LJ"

#     input = "
# ...........
# .S-------7.
# .|F-----7|.
# .||.....||.
# .||.....||.
# .|L-7.F-J|.
# .|..|.|..|.
# .L--J.L--J.
# ..........."

# input = ".F----7F7F7F7F-7....
# .|F--7||||||||FJ....
# .||.FJ||||||||L7....
# FJL7L7LJLJ||LJ.L-7..
# L--J.L7...LJS7F-7L7.
# ....F-J..F7FJ|L7L7L7
# ....L7.F7||L7|.L7L7|
# .....|FJLJ|FJ|F7|.LJ
# ....FJL-7.||.||||...
# ....L---J.LJ.LJLJ..."

# input = "FF7FSF7F7F7F7F7F---7
# L|LJ||||||||||||F--J
# FL-7LJLJ||||||LJL-77
# F--JF--7||LJLJ7F7FJ-
# L---JF-JLJ.||-FJLJJ7
# |F|F-JF---7F7-L7L|7|
# |FFJF7L7F-JF7|JL---7
# 7-L-JL7||F7|L7F-7F7|
# L.L7LFJ|||||FJL7||LJ
# L7JLJL-JLJLJL--JLJ.L"

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
    # IO.inspect(path, label: "path")

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

      # i'm making an assumption here there will only ever be one valid move, when excluding where we came from.
      # when we're at S at depth 0, we can just pick one at random I think so find is fine.
      valid_move = Enum.find(possible_moves, fn {x, y, dir} -> 
        # IO.inspect({x, y, dir})
        # IO.inspect(Helpers.CalbeGrid.get_by_x_y(grid, x, y))
        # IO.inspect(valid_south_connections)

        case dir do
          :north -> Enum.member?(valid_north_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          :south -> Enum.member?(valid_south_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          :east -> Enum.member?(valid_east_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
          :west -> Enum.member?(valid_west_connections, Helpers.CalbeGrid.get_by_x_y(grid, x, y))
        end
      end)


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

  defp get_all_adjacent_non_mainloop_coords(grid, {x, y}, main_loop) do

    # IO.inspect({x, y}, label: "get_all_adjacent_non_mainloop_coords")
    possible_moves = [
      {0, -1},
      {0, 1},
      {1, 0},
      {-1, 0}
    ]

    
    Enum.map(possible_moves, fn {x_offset, y_offset} -> 
      {x + x_offset, y + y_offset, Helpers.CalbeGrid.get_by_x_y(grid, x + x_offset, y + y_offset)}
    end)
    # |> IO.inspect(label: "possible_moves")
    |> Enum.filter(fn {x, y, cell_value} -> 
      !Enum.member?(main_loop, {x, y})
      && cell_value != nil
    end)
    # |> IO.inspect(label: "filtered_possible_moves")

  end

  def flood_fill_cluster(grid, start_x, start_y, main_loop, cluster \\ %{cluster: [], latest: []}) do
    # IO.inspect({start_x, start_y}, label: "flood_fill_cluster")
    # IO.inspect(cluster, label: "cluster")
    # IO.inspect(cluster[:latest])

    cluster = if (cluster[:latest] == []) do
      %{
        cluster: [{start_x, start_y, Helpers.CalbeGrid.get_by_x_y(grid, start_x, start_y)}],
        latest: [{start_x, start_y, Helpers.CalbeGrid.get_by_x_y(grid, start_x, start_y)}]
      }
    else
      cluster
    end

    new_additions = Enum.flat_map(cluster[:latest], fn {x, y, _symbol} -> 
      get_all_adjacent_non_mainloop_coords(grid, {x, y}, main_loop)
    end)
    |> Enum.uniq()
    |> Enum.filter(fn {x, y, sym} -> 
      !Enum.member?(cluster[:cluster], {x, y, sym})
    end)
    
    IO.inspect(length(new_additions), label: "length of new_additions")

    new_cluster = Enum.uniq(cluster[:cluster] ++ new_additions)

    newly_reached_terminus = Enum.find(new_additions, fn {x, y, _symbol} -> 
      # IO.inspect({x, y}, label: "new_additions")
      x < 1 || x >= (Helpers.CalbeGrid.get_grid_width(grid) - 1) || y < 1 || y >= (Helpers.CalbeGrid.get_grid_len(grid) - 1)
    end)

    if (newly_reached_terminus) do
      IO.puts("_________newly_reached_terminus_________")
    end

    if (length(new_cluster) == length(cluster[:cluster]) || newly_reached_terminus) do
      # IO.puts("cluster is complete")
      # IO.inspect(cluster, label: "final cluster")
      new_cluster
    else
      flood_fill_cluster(grid, start_x, start_y, main_loop, %{
        cluster: new_cluster,
        latest: new_additions
      })
    end
    
  end

  def get_allowed_squeeze_directions(symbol) do 

    #note may need to add "S" to this list
    #that will mean inferring what it is.
    #probably just replace it in the grid.

    case symbol do
      "7" -> [:west, :south]
      "F" -> [:east, :south]
      "L" -> [:north, :east]
      "J" -> [:north, :west]
      "|" -> [:north, :south]
      "-" -> [:east, :west]
      _ -> []
    end
  end

  # defp walk_squeeze_paths(grid, paths, visited_cells) do

    
  
  # end

  # defp get_can_squeeze_between_pipes_to_outside(grid, {x, y}) do



  # end

  def get_what_cell_should_be(grid, {x, y}) do
    surroundings = [
      {0, -1, :north},
      {0, 1, :south},
      {1, 0, :east},
      {-1, 0, :west}
    ]
    |> Enum.map(fn {x_offset, y_offset, dir} -> 
      {dir, Helpers.CalbeGrid.get_by_x_y(grid, x + x_offset, y + y_offset)}
    end)
    # to map format
    |> Enum.reduce(%{}, fn {dir, cell}, acc -> 
      Map.put(acc, dir, cell)
    end)

    valid_north_connections = ["|", "7", "F", "S"]
    valid_south_connections = ["|", "L", "J", "S"]
    valid_east_connections = ["-", "J", "7", "S"]
    valid_west_connections = ["-", "L", "F", "S"]


    #if north is in valid_north_connections, and south is in valid_south_connections, we are "|"
    #if east is in valid_east_connections, and west is in valid_west_connections, we are "-"
    #if north is in valid_north_connections, and east is in valid_east_connections, we are "L"
    #if north is in valid_north_connections, and west is in valid_west_connections, we are "J"
    #if south is in valid_south_connections, and east is in valid_east_connections, we are "F"
    #if south is in valid_south_connections, and west is in valid_west_connections, we are "7"

    new_val = cond do
      Enum.member?(valid_north_connections, surroundings[:north]) && Enum.member?(valid_south_connections, surroundings[:south]) -> "|"
      Enum.member?(valid_east_connections, surroundings[:east]) && Enum.member?(valid_west_connections, surroundings[:west]) -> "-"
      Enum.member?(valid_north_connections, surroundings[:north]) && Enum.member?(valid_east_connections, surroundings[:east]) -> "L"
      Enum.member?(valid_north_connections, surroundings[:north]) && Enum.member?(valid_west_connections, surroundings[:west]) -> "J"
      Enum.member?(valid_south_connections, surroundings[:south]) && Enum.member?(valid_east_connections, surroundings[:east]) -> "F"
      Enum.member?(valid_south_connections, surroundings[:south]) && Enum.member?(valid_west_connections, surroundings[:west]) -> "7"
      true -> ","
    end
        
  end

  def part2(_args) do

    input = get_parsed_input()

    # main_loop = crawl_main_loop(input, [start], 0)

    # cleaned_grid = Enum.reduce(main_loop, input, fn {x, y}, acc -> 
    #   Helpers.CalbeGrid.set_by_x_y(acc, x, y, "M")
    # end)
    # |> Helpers.CalbeGrid.visualize_grid()

    # enclosed_clusters = Enum.filter(clusters_which_dont_touch_any_edge, fn cluster -> 
    #   Enum.all?(cluster, fn {x, y, _symbol} -> 
    #     possible_moves = [
    #       {0, -1},
    #       {0, 1},
    #       {1, 0},
    #       {-1, 0}
    #     ]
    
        
    #     Enum.map(possible_moves, fn {x_offset, y_offset} -> 
    #       {x + x_offset, y + y_offset, Helpers.CalbeGrid.get_by_x_y(cleaned_grid, x + x_offset, y + y_offset)}
    #     end)
    #     |> Enum.all?(fn {x, y, cell_value} -> 
    #       cell_value == "M" || cell_value == "."
    #     end)

    #   end)
    # end)

    # map_for_vis = Enum.reduce(enclosed_clusters, cleaned_grid, fn cluster, acc -> 
    #   Enum.reduce(cluster, acc, fn {x, y, _symbol}, acc -> 
    #     Helpers.CalbeGrid.set_by_x_y(acc, x, y, "I")
    #   end)
    # end)
    # |> Helpers.CalbeGrid.visualize_grid()

    grid_showing_space_between_pipes = "," <> (Helpers.CalbeGrid.extract_text_representation(input, "\n", "")
    |> String.split("", trim: true)
    |> Enum.join(","))

    new_row_len = String.split(grid_showing_space_between_pipes, "\n", trim: true)
    |> Enum.at(0)
    |> String.length()

    new_row = String.duplicate(",", new_row_len)

    grid_showing_space_between_pipes_pre_fill = String.split(grid_showing_space_between_pipes, "\n", trim: true)
    |> Enum.join(
      "\n" <> new_row <> "\n"
    )
    |> Helpers.CalbeGrid.parse("\n", "")


    #for every comma, fill in what it should be if anything
    grid_showing_space_between_pipes_post_fill = Enum.reduce(0..(Helpers.CalbeGrid.get_grid_len(grid_showing_space_between_pipes_pre_fill) - 1), grid_showing_space_between_pipes_pre_fill, fn y, acc -> 

      Enum.reduce(0..(Helpers.CalbeGrid.get_grid_width(grid_showing_space_between_pipes_pre_fill) - 1), acc, fn x, acc -> 
        if (Helpers.CalbeGrid.get_by_x_y(acc, x, y) == ",") do
          Helpers.CalbeGrid.set_by_x_y(acc, x, y, get_what_cell_should_be(acc, {x, y}))
        else
          acc
        end
      end)
      
    end)
    # |> IO.inspect()
    |> Helpers.CalbeGrid.visualize_grid()

    start = Helpers.CalbeGrid.find_point(grid_showing_space_between_pipes_post_fill, fn x -> x == "S" end)

    grid_len = Helpers.CalbeGrid.get_grid_len(grid_showing_space_between_pipes_post_fill)
    grid_width = Helpers.CalbeGrid.get_grid_width(grid_showing_space_between_pipes_post_fill)

    main_loop = crawl_main_loop(grid_showing_space_between_pipes_post_fill, [start], 0)

    # replace S with whatever it should be
    grid_showing_space_between_pipes_post_fill = Helpers.CalbeGrid.set_by_x_y(grid_showing_space_between_pipes_post_fill, start |> elem(0), start |> elem(1), get_what_cell_should_be(grid_showing_space_between_pipes_post_fill, start))

    # loop back through everything, if we replaced it earlier with something, but it isn't a member of main loop, let's un-replace it.
    grid_showing_space_between_pipes_revert_nonloop = Enum.reduce(0..(Helpers.CalbeGrid.get_grid_len(grid_showing_space_between_pipes_post_fill) - 1), grid_showing_space_between_pipes_post_fill, fn y, acc -> 

      Enum.reduce(0..(Helpers.CalbeGrid.get_grid_width(grid_showing_space_between_pipes_post_fill) - 1), acc, fn x, acc -> 
        if (Helpers.CalbeGrid.get_by_x_y(grid_showing_space_between_pipes_pre_fill, x, y) == "," && !Enum.member?(main_loop, {x, y})) do
          Helpers.CalbeGrid.set_by_x_y(acc, x, y, ",")
        else
          acc
        end
      end)
      
    end)

    IO.puts("final grid solidified")

    clusters = Enum.reduce(1..(grid_len - 2), [], fn curr_y, acc -> 
      new_clusters_found_via_row = Enum.reduce(1..(grid_width - 2), [], fn curr_x, inner_acc -> 
        if (
          # Helpers.CalbeGrid.get_by_x_y(grid_showing_space_between_pipes, curr_x, curr_y) == "."
          #ensure the point we're considering isn't part of main loop
          !Enum.member?(main_loop, {curr_x, curr_y})
          && !Enum.any?(acc, fn cluster -> 
            # Enum.member?(cluster, {curr_x, curr_y, "."})
            Enum.find(cluster, fn {x, y, _symbol} -> 
              x == curr_x && y == curr_y
            end) != nil
          end)
          && !Enum.any?(inner_acc, fn cluster -> 
            # Enum.member?(cluster, {curr_x, curr_y, "."})
            Enum.find(cluster, fn {x, y, _symbol} -> 
              x == curr_x && y == curr_y
            end) != nil
          end)
        ) do
          IO.inspect({curr_x, curr_y}, label: "a new cluster has been discovered, filling...")
          cluster = flood_fill_cluster(grid_showing_space_between_pipes_revert_nonloop, curr_x, curr_y, main_loop)
          # IO.inspect(cluster, label: "cluster")
          [cluster] ++ inner_acc
        else
          inner_acc
        end
      end)

      acc ++ new_clusters_found_via_row
    end)
    |> IO.inspect(label: "clusters")

    
    Enum.reduce(clusters, "", fn cluster, acc -> 
      acc <> "\n" <> Enum.reduce(cluster, "", fn {x, y, symbol}, acc -> 
        acc <> "#{x},#{y},#{symbol}"
      end)
    end)
    |> Helpers.Utils.dump_to_file("clusters.txt")
    
    # IO.inspect(grid_len, label: "grid_len")
    # IO.inspect(grid_width, label: "grid_width")

    clusters_which_dont_touch_any_edge = Enum.filter(clusters, fn cluster -> 

      Enum.all?(cluster, fn {x, y, _symbol} -> 
        x > 0 && x < (grid_width - 1) && y > 0 && y < (grid_len - 1)
      end)
    end)
    # |> IO.inspect(label: "clusters_which_dont_touch_any_edge")

    Enum.map(clusters_which_dont_touch_any_edge, fn cluster -> 
      Enum.filter(cluster, fn {x, y, symbol} -> 
        symbol != ","
      end)
    end)
    |> Enum.reduce("", fn cluster, acc -> 
      acc <> "\n" <> Enum.reduce(cluster, "", fn {x, y, symbol}, acc -> 
        acc <> "#{x},#{y},#{symbol}\n"
      end)
    end)
    # |> Helpers.Utils.dump_to_file("clusters_which_dont_touch_any_edge.txt")

    # IO.inspect(length(clusters_which_dont_touch_any_edge), label: "length of clusters_which_dont_touch_any_edge")
    
    Enum.reduce(clusters_which_dont_touch_any_edge, 0, fn cluster, acc -> 
      period_count = Enum.filter(cluster, fn {_x, _y, symbol} -> 
        symbol != ","
      end)
      |> length()

      acc + period_count
    end)

  end
end
