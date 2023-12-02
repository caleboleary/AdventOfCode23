defmodule AdventOfCode.Day02 do
  
  defp getCountsShownInRoundPart(roundPart) do

    initAcc = %{
      "red" => 0,
      "green" => 0,
      "blue" => 0
    }
    
    Enum.reduce(roundPart, initAcc, fn curr, acc -> 

      %{
        "red" => if String.contains?(curr, "red") do
          acc["red"] + (Integer.parse(Regex.replace(~r/[^\d+]/, curr, "")) |> elem(0))
        else
          acc["red"]
        end,
        "green" => if String.contains?(curr, "green") do
          acc["green"] + (Integer.parse(Regex.replace(~r/[^\d+]/, curr, "")) |> elem(0))
        else
          acc["green"]
        end,
        "blue" => if String.contains?(curr, "blue") do
          acc["blue"] + (Integer.parse(Regex.replace(~r/[^\d+]/, curr, "")) |> elem(0))
        else
          acc["blue"]
        end,
      }
      
    end)

  end

  def part1(_args) do
    input = AdventOfCode.Input.get!(2, 2023)

#     input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
# Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
# Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
# Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
# Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"

    possibleFilter = %{
      # only 12 red cubes, 13 green cubes, and 14 blue cubes
      "red" => 12,
      "green" => 13,
      "blue" => 14
    }

    games = String.split(input, "\n", trim: true)

    rounds = Enum.map(games, fn game -> 
      round = Regex.replace(~r/Game \d+\:/, game, "") |> String.split(";", trim: true) 
      Enum.map(round, fn roundPart -> 
        String.split(roundPart, ",", trim: true) |> Enum.map(fn s -> String.trim(s) end)
      end)
    end)
    

    results = Enum.map(rounds, fn round -> 
      result = Enum.map(round, fn roundPart -> 
        getCountsShownInRoundPart(roundPart)
      end)
    end)

    # IO.inspect(results)

    Enum.with_index(results) |> Enum.reduce(0, fn curr, acc -> 
      {round, index} = curr
      impossible = Enum.filter(round, fn roundPart -> 
        roundPart["red"] > possibleFilter["red"] || 
        roundPart["green"] > possibleFilter["green"] || 
        roundPart["blue"] > possibleFilter["blue"] 
      end)

      # IO.inspect(impossible)

      newAcc = if (Enum.count(impossible) > 0) do
        acc
      else
        acc + (index + 1)
      end

    
    end)

  end

  defp getRoundPower(round) do
    round["red"] * round["blue"] * round["green"]
  end

  def part2(_args) do

    input = AdventOfCode.Input.get!(2, 2023)

#     input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
# Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
# Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
# Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
# Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"

    possibleFilter = %{
      # only 12 red cubes, 13 green cubes, and 14 blue cubes
      "red" => 12,
      "green" => 13,
      "blue" => 14
    }

    games = String.split(input, "\n", trim: true)

    rounds = Enum.map(games, fn game -> 
      round = Regex.replace(~r/Game \d+\:/, game, "") |> String.split(";", trim: true) 
      Enum.map(round, fn roundPart -> 
        String.split(roundPart, ",", trim: true) |> Enum.map(fn s -> String.trim(s) end)
      end)
    end)
    

    results = Enum.map(rounds, fn round -> 
      result = Enum.map(round, fn roundPart -> 
        getCountsShownInRoundPart(roundPart)
      end)
    end)

    initAcc = %{
      "red" => 0,
      "green" => 0,
      "blue" => 0
    }
    

    Enum.map(results, fn curr -> 

      Enum.reduce(curr, initAcc, fn currPart, acc -> 
       
        %{
          "red" => if (currPart["red"] > acc["red"]) do
            currPart["red"]
          else
            acc["red"]
          end,
          "green" => if (currPart["green"] > acc["green"]) do
            currPart["green"]
          else
            acc["green"]
          end,
          "blue" => if (currPart["blue"] > acc["blue"]) do
            currPart["blue"]
          else
            acc["blue"]
          end,
        }
      end) |> getRoundPower()
      
    end)
    |> IO.inspect()
    |> Enum.reduce(0, fn currTotal, num -> currTotal + num end)

  end
end
