defmodule AdventOfCode.Day08 do

  defp get_parsed_input do
    input = AdventOfCode.Input.get!(8, 2023)

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

  defp traverse(directions, locations, step_index, current_location) do

    if (current_location == "ZZZ") do
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

  def part1(_args) do

    input = get_parsed_input()

    traverse(input.directions, input.locations, 0, "AAA")



  end

  def part2(_args) do
  end
end
