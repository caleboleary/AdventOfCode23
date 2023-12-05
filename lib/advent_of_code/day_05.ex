defmodule AdventOfCode.Day05 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(5, 2023)
#     input = "seeds: 79 14 55 13

# seed-to-soil map:
# 50 98 2
# 52 50 48

# soil-to-fertilizer map:
# 0 15 37
# 37 52 2
# 39 0 15

# fertilizer-to-water map:
# 49 53 8
# 0 11 42
# 42 0 7
# 57 7 4

# water-to-light map:
# 88 18 7
# 18 25 70

# light-to-temperature map:
# 45 77 23
# 81 45 19
# 68 64 13

# temperature-to-humidity map:
# 0 69 1
# 1 0 69

# humidity-to-location map:
# 60 56 37
# 56 93 4"

    split = String.split(input, "\n\n", trim: true)

    seeds = Enum.take(split, 1)
    |> Enum.at(0)
    |> String.replace(~r/seeds:/, "")
    |> String.split(" ", trim: true)
    |> Enum.map(fn seed_str -> 
      Integer.parse(seed_str) 
      |> elem(0) 
    end)

    maps = Enum.slice(split, 1..-1)
    |> Enum.map(fn map_str -> 
      split_map = String.split(map_str, "\n", trim: true)

      from_to_list = split_map
      |> Enum.at(0)
      |> String.replace(~r/\smap:/, "")
      |> String.split("-to-")

      from_to = %{
        from: Enum.at(from_to_list, 0),
        to: Enum.at(from_to_list, 1),
      }

      converters = Enum.slice(split_map, 1..-1)
      |> Enum.map(fn converter_line -> 
        split_converter = String.split(converter_line, " ", trim: true)
        |> Enum.map(fn converter_item -> 
          Integer.parse(converter_item) 
          |> elem(0) 
        end)
      end)
      |> Enum.map(fn converter_list -> 
        %{
          dest_range_start: Enum.at(converter_list, 0),
          source_range_start: Enum.at(converter_list, 1),
          range_len: Enum.at(converter_list, 2),
        }
      end)

      %{
        from_to: from_to,
        converters: converters
      }
    end)

    %{
      seeds: seeds,
      maps: maps
    }
    
  end

  defp convert_number(number, converter) do
    if (converter == nil) do
      number
    else
      number + (converter[:dest_range_start] - converter[:source_range_start])
    end
  end

  defp get_location_nums(seeds, maps, reverse \\ false) do
    
    converter_order = [
      "seed", 
      "soil", 
      "fertilizer", 
      "water", 
      "light", 
      "temperature", 
      "humidity", 
      "location"
    ]

    Enum.map(seeds, fn seed -> 
      
      Enum.with_index(converter_order)
      |> Enum.reduce([], fn {current_converter, index}, acc -> 

        if (index == 0) do
          [seed]
        else
          from = Enum.at(converter_order, index - 1)
          to = current_converter
          current_num = Enum.at(acc, -1)

          converters = maps
          |> Enum.find(fn map -> 
            map[:from_to][:from] == from && map[:from_to][:to] == to
          end)
          |> Map.get(:converters)

          relevant_converter = Enum.find(converters, fn converter -> 
            current_num >= converter[:source_range_start] && current_num < converter[:source_range_start] + converter[:range_len]
          end)

          acc ++ [convert_number(current_num, relevant_converter)]
        end

      end)
      
    end)
    |> Enum.map(fn numer_trail -> 
      Enum.at(numer_trail, -1)
    end)
  end

  def part1(_args) do
    parsed = get_parsed_input()

    location_nums = get_location_nums(parsed[:seeds], parsed[:maps])

    Enum.sort(location_nums) 
    |> Enum.at(0)

  end

  def invert_mappings(mappings) do
    Enum.map(mappings, fn mapping -> 
      IO.puts("----")
      IO.inspect(mapping)
      %{
        from_to: %{from: mapping[:from_to][:to], to: mapping[:from_to][:from]},
        converters: Enum.map(mapping[:converters], fn converter -> 
          %{dest_range_start: converter[:source_range_start], range_len: converter[:range_len], source_range_start: converter[:dest_range_start]}
        end)
      }
      |> IO.inspect()
    end)
  end

  def get_seed_from_location(location, maps) do
    converter_order = [
      "seed", 
      "soil", 
      "fertilizer", 
      "water", 
      "light", 
      "temperature", 
      "humidity", 
      "location"
    ] |> Enum.reverse()
    
    Enum.with_index(converter_order)
      |> Enum.reduce([], fn {current_converter, index}, acc -> 

        if (index == 0) do
          [location]
        else
          from = Enum.at(converter_order, index - 1)
          to = current_converter
          current_num = Enum.at(acc, -1)

          converters = maps
          |> Enum.find(fn map -> 
            map[:from_to][:from] == from && map[:from_to][:to] == to
          end)
          |> Map.get(:converters)

          relevant_converter = Enum.find(converters, fn converter -> 
            current_num >= converter[:source_range_start] && current_num < converter[:source_range_start] + converter[:range_len]
          end)

          acc ++ [convert_number(current_num, relevant_converter)]
        end

      end)
      |> Enum.at(-1)
      

  end

  defp get_lowest_location(number, mappings, seed_ranges) do
    seed = get_seed_from_location(number, mappings)

    if (rem(number, 1000000) == 0) do
      IO.puts(number)
    end

    contained_in_range = Enum.find(seed_ranges, fn seed_range -> 
      seed >= seed_range[:start] && seed < seed_range[:start] + seed_range[:end]
    end)

    if (contained_in_range == nil) do
      get_lowest_location(number + 1, mappings, seed_ranges)
    else
      number
    end
  end

  def part2(_args) do
    parsed = get_parsed_input()

    seed_ranges = parsed[:seeds]
    |> Enum.reduce([], fn curr_seed, acc -> 
      IO.inspect(curr_seed)
      latest = Enum.at(acc, -1)

      if (acc == [] || latest[:end] != nil) do
        acc ++ [%{start: curr_seed}]
      else
        List.replace_at(acc, -1, %{start: latest[:start], end: curr_seed})
      end
    end)
    |> Helpers.Utils.inspect()

    inverted = invert_mappings(parsed[:maps])

    get_lowest_location(0, inverted, seed_ranges)
    

    # seeds = Enum.flat_map(seed_ranges, fn seed_range -> 
    #   seed_range[:start]..(seed_range[:start] + seed_range[:end])
    # end)
    # |> Helpers.Utils.inspect()


    # location_nums = get_location_nums(seeds, parsed[:maps])

    # Enum.sort(location_nums) 
    # |> Enum.at(0)

  end
end
