defmodule AdventOfCode.Day06 do

  defp get_parsed_input(is_part_2 \\ false) do
    input = AdventOfCode.Input.get!(6, 2023)
#     input = "Time:      7  15   30
# Distance:  9  40  200"

    input = if is_part_2 do
      String.replace(input, " ", "")
    else
      input
    end

    arrs = String.split(input, "\n", trim: true)
    |> Enum.map(fn line -> 
      String.split(line, ":", trim: true)
      |> Enum.at(-1)
      |> String.split(" ", trim: true)
      |> Enum.map(fn num_str -> 
        Integer.parse(num_str) |> elem(0)
      end)
    end)

    %{
      race_times: Enum.at(arrs, 0),
      records: Enum.at(arrs, 1)
    }
    
  end

  defp get_distance_traveled(time_charged, total_time) do

    speed = time_charged

    remaining_time = total_time - time_charged

    remaining_time * speed

  end

  def part1(_args) do

    input = get_parsed_input();

    Enum.map(input[:race_times], fn race_time -> 
      0..race_time
      |> Enum.map(fn time_charged -> 
        get_distance_traveled(time_charged, race_time)
      end)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {times, index} -> 
      Enum.filter(times, fn time -> 
        time > Enum.at(input[:records], index)
      end)
      |> length()
    end)
    |> Enum.reduce(1, fn currTotal, num -> currTotal * num end)
    


  end

  def part2(_args) do

    input = get_parsed_input(true)

    Enum.map(input[:race_times], fn race_time -> 
      0..race_time
      |> Enum.map(fn time_charged -> 
        get_distance_traveled(time_charged, race_time)
      end)
    end)
    |> Helpers.Utils.inspect()
    |> Enum.with_index()
    |> Enum.map(fn {times, index} -> 
      Enum.filter(times, fn time -> 
        time > Enum.at(input[:records], index)
      end)
      |> length()
    end)
    |> IO.inspect()
    |> Enum.reduce(1, fn currTotal, num -> currTotal * num end)
  end
end
