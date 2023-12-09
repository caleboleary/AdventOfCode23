defmodule AdventOfCode.Day08 do

  defp get_parsed_input(input) do
    # input = AdventOfCode.Input.get!(8, 2023)

    #  # 6
#     input = "LLR

# AAA = (BBB, BBB)
# BBB = (AAA, ZZZ)
# ZZZ = (ZZZ, ZZZ)"

#     # # 2
#     input = "RL

# AAA = (BBB, CCC)
# BBB = (DDD, EEE)
# CCC = (ZZZ, GGG)
# DDD = (DDD, DDD)
# EEE = (EEE, EEE)
# GGG = (GGG, GGG)
# ZZZ = (ZZZ, ZZZ)"

    # # 6
#     input = "LR

# 11A = (11B, XXX)
# 11B = (XXX, 11Z)
# 11Z = (11B, XXX)
# 22A = (22B, XXX)
# 22B = (22C, 22C)
# 22C = (22Z, 22Z)
# 22Z = (22B, 22B)
# XXX = (XXX, XXX)"

    [directions, locations] = input
    |> String.split("\n\n", trim: true)

    locations = String.split(locations, "\n", trim: true)
    |> Enum.reduce(%{}, fn location, acc ->
      [name, connections] = String.split(location, " = ", trim: true)
      connections = String.split(connections, ", ", trim: true)
      |> Enum.flat_map(fn connection ->
        String.replace(connection, "(", "")
        |> String.replace(")", "")
        |> String.split(" ", trim: true)
      end)

      Map.put(acc, name, connections)
    end)
    

    %{
      directions: directions,
      locations: locations
    }

  end

  defp traverse(directions, locations, step_index, current_location, terminus \\ "ZZZ") do

    if (current_location == terminus) do
      step_index
    else 

      wrapped_step_index = rem(step_index, String.length(directions))

      current_direction = String.at(directions, wrapped_step_index)

      index = if (current_direction == "L") do
        0
      else
        1
      end

      traverse(
        directions,
        locations,
        step_index + 1,
        locations[current_location] |> Enum.at(index)
      )
    end
    
  end

  def part1(args) do

    input = get_parsed_input(args)

    traverse(input.directions, input.locations, 0, "AAA")
    

  end

  defp process_parallel_paths(directions, locations, step_index, paths) do

    if (rem(step_index, 1000) == 0) do
      IO.inspect(step_index)
      # IO.inspect(Enum.at(paths, 0) |> length())
      IO.puts("-----")
    end

    Enum.map(paths, fn path -> 
      current_location = Enum.at(path, -1)

      wrapped_step_index = rem(step_index, String.length(directions))

      current_direction = String.at(directions, wrapped_step_index)

      index = if (current_direction == "L") do
        0
      else
        1
      end

      new_path = [locations[current_location] |> Enum.at(index)]
      
    end)
  end

  defp get_do_all_paths_terminate_in_Z(paths) do
    # IO.inspect(paths)
    Enum.all?(paths, fn path -> 
      String.ends_with?(Enum.at(path, -1), "Z")
    end)
  end

  defp traverse_pt2(directions, locations, step_index, current_location) do

    if (String.ends_with?(current_location, "Z")) do
      step_index
    else 

      wrapped_step_index = rem(step_index, String.length(directions))

      current_direction = String.at(directions, wrapped_step_index)

      index = if (current_direction == "L") do
        0
      else
        1
      end

      traverse_pt2(
        directions,
        locations,
        step_index + 1,
        locations[current_location] |> Enum.at(index)
      )
    end
    
  end

  # defp simulate_n_steps(directions, locations, step_index, path, total_steps) do

  #   IO.inspect(step_index)
  #   IO.inspect(path)

  #   if (step_index >= total_steps || Enum.at(path, -1) |> String.ends_with?("Z")) do
  #     IO.inspect(step_index)
      
  #     path
  #   else 

  #     wrapped_step_index = rem(step_index, String.length(directions))

  #     current_location = Enum.at(path, -1)

  #     current_direction = String.at(directions, wrapped_step_index)

  #     index = if (current_direction == "L") do
  #       0
  #     else
  #       1
  #     end

  #     simulate_n_steps(
  #       directions,
  #       locations,
  #       step_index + 1,
  #       path ++ [locations[current_location] |> Enum.at(index)],
  #       total_steps
  #     )
  #   end
    
  # end


  def part2(args) do

    input = get_parsed_input(args)

    all_locs_ending_in_A = input[:locations]
    |> Enum.filter(fn {name, _} -> String.ends_with?(name, "A") end)
    |> Enum.flat_map(fn {name, _} -> [name] end)

    steps_until_z = Enum.map(all_locs_ending_in_A, fn loc -> 
      traverse_pt2(input[:directions], input[:locations], 0, loc)
    end)

    #lcm of all numbers
    Enum.reduce(steps_until_z, 1, fn x, acc ->
      Math.lcm(x, trunc(acc))
    end)

    # sim = simulate_n_steps(input[:directions], input[:locations], 0, all_locs_ending_in_A, 1000000)

    # sim2 = simulate_n_steps(input[:directions], input[:locations], 0, [Enum.at(sim, -1)], 2)


    # Enum.reduce_while(1..100, 0, fn x, acc ->
    #   if x < 5, do: {:cont, acc + x}, else: {:halt, acc}
    # end)

    # path_len = Enum.reduce_while(10000000..100000000, all_locs_ending_in_A, fn curr_depth, paths ->
      
    #   if get_do_all_paths_terminate_in_Z(paths) do
    #     {:halt, curr_depth}
    #   else
    #     {:cont, process_parallel_paths(input[:directions], input[:locations], curr_depth, paths)}
    #   end
    # end)

  end
end
